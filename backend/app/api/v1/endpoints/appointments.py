from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from typing import List
from datetime import datetime, timedelta

from app.api.deps import get_db, get_current_active_user
from app.models.user import User
from app.models.appointment import Appointment, AppointmentType, AppointmentStatus
from app.models.shop_services import Service
from app.schemas.appointment import AppointmentCreate, AppointmentOut, AppointmentUpdate
from app.api.v1.endpoints.websocket import manager

router = APIRouter()

@router.post("/book", response_model=AppointmentOut, status_code=status.HTTP_201_CREATED)
async def book_appointment(
    appointment_in: AppointmentCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    if not appointment_in.service_ids:
        raise HTTPException(status_code=400, detail="At least one service must be selected.")

    # Fetch services to make sure they belong to the shop
    result = await db.execute(
        select(Service).where(Service.id.in_(appointment_in.service_ids))
    )
    services = result.scalars().all()

    if len(services) != len(set(appointment_in.service_ids)):
        raise HTTPException(status_code=404, detail="One or more services not found.")

    for svc in services:
        if str(svc.shop_id) != str(appointment_in.shop_id):
            raise HTTPException(status_code=400, detail="Services do not belong to the selected shop.")

    # Strip timezone for PostgreSQL TIMESTAMP WITHOUT TIME ZONE
    scheduled_time_naive = appointment_in.scheduled_time.replace(tzinfo=None) if appointment_in.scheduled_time else None

    new_appointment = Appointment(
        customer_id=current_user.id,
        shop_id=appointment_in.shop_id,
        staff_id=appointment_in.staff_id,
        type=appointment_in.type,
        scheduled_time=scheduled_time_naive,
        status=AppointmentStatus.PENDING
    )

    if appointment_in.type == AppointmentType.SCHEDULED:
        if not scheduled_time_naive:
            raise HTTPException(status_code=400, detail="Scheduled time is required for SCHEDULED type.")

        # Conflict check for scheduled appointments
        duration = sum([svc.duration_minutes for svc in services])
        end_time = scheduled_time_naive + timedelta(minutes=duration)

        if appointment_in.staff_id is not None:
            # Conflict check for specific staff
            conflict_query = select(Appointment).where(
                Appointment.shop_id == appointment_in.shop_id,
                Appointment.staff_id == appointment_in.staff_id,
                Appointment.type == AppointmentType.SCHEDULED,
                Appointment.status.in_([AppointmentStatus.PENDING, AppointmentStatus.APPROVED]),
                Appointment.scheduled_time < end_time,
                Appointment.scheduled_time + timedelta(minutes=30) > scheduled_time_naive
            )
            conflict_result = await db.execute(conflict_query)
            if conflict_result.scalars().first():
                raise HTTPException(status_code=409, detail="Seçilen usta bu saatte dolu.")
        else:
            # Conflict check for shop capacity (Fark Etmez)
            # Find all staff in the shop
            from app.models.shop_services import Staff
            staff_result = await db.execute(select(Staff).where(Staff.shop_id == appointment_in.shop_id))
            all_staff = staff_result.scalars().all()
            if not all_staff:
                raise HTTPException(status_code=400, detail="Dükkanın kayıtlı ustası bulunamadı.")

            # For each staff, check if they are busy at this time
            available_staff = []
            for staff in all_staff:
                staff_conflict_query = select(Appointment).where(
                    Appointment.shop_id == appointment_in.shop_id,
                    Appointment.staff_id == staff.id,
                    Appointment.type == AppointmentType.SCHEDULED,
                    Appointment.status.in_([AppointmentStatus.PENDING, AppointmentStatus.APPROVED]),
                    Appointment.scheduled_time < end_time,
                    Appointment.scheduled_time + timedelta(minutes=30) > scheduled_time_naive
                )
                staff_conflict_result = await db.execute(staff_conflict_query)
                if not staff_conflict_result.scalars().first():
                    available_staff.append(staff)

            # Also check for appointments that don't have a staff_id yet (if any)
            none_staff_conflict_query = select(Appointment).where(
                Appointment.shop_id == appointment_in.shop_id,
                Appointment.staff_id.is_(None),
                Appointment.type == AppointmentType.SCHEDULED,
                Appointment.status.in_([AppointmentStatus.PENDING, AppointmentStatus.APPROVED]),
                Appointment.scheduled_time < end_time,
                Appointment.scheduled_time + timedelta(minutes=30) > scheduled_time_naive
            )
            none_staff_result = await db.execute(none_staff_conflict_query)
            none_staff_appointments = len(none_staff_result.scalars().all())

            # Effective available slots
            if len(available_staff) <= none_staff_appointments:
                raise HTTPException(status_code=409, detail="Bu saatte tüm ustalar dolu.")

            # Assign one of the available staff members
            # We skip staff who are already "taken" by none_staff_appointments
            # For simplicity, just pick the first available staff that isn't explicitly booked
            new_appointment.staff_id = available_staff[none_staff_appointments].id

    elif appointment_in.type == AppointmentType.LIVE_QUEUE:
        # Assign next queue number
        queue_result = await db.execute(
            select(Appointment).where(
                Appointment.shop_id == appointment_in.shop_id,
                Appointment.type == AppointmentType.LIVE_QUEUE,
                # Appointment.created_at >= datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
            ).order_by(Appointment.queue_number.desc()).limit(1)
        )
        last_in_queue = queue_result.scalar_one_or_none()
        next_number = (last_in_queue.queue_number or 0) + 1 if last_in_queue else 1
        new_appointment.queue_number = next_number

    # Add services
    new_appointment.services.extend(services)

    db.add(new_appointment)
    await db.commit()
    await db.refresh(new_appointment)

    # Need to reload with relationships
    result = await db.execute(
        select(Appointment)
        .options(selectinload(Appointment.services), selectinload(Appointment.staff), selectinload(Appointment.customer))
        .where(Appointment.id == new_appointment.id)
    )
    appointment_out = result.scalar_one()

    # Broadcast to WebSocket
    await manager.broadcast_json(
        str(appointment_out.shop_id),
        {
            "event": "appointment_booked",
            "appointment_id": str(appointment_out.id),
            "type": appointment_out.type,
            "queue_number": appointment_out.queue_number,
        }
    )

    return appointment_out

@router.get("/me", response_model=List[AppointmentOut])
async def get_my_appointments(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    result = await db.execute(
        select(Appointment)
        .options(selectinload(Appointment.services), selectinload(Appointment.staff), selectinload(Appointment.customer))
        .where(Appointment.customer_id == current_user.id)
        .order_by(Appointment.created_at.desc())
    )
    appointments = result.scalars().all()
    return appointments

@router.get("/shop/{shop_id}", response_model=List[AppointmentOut])
async def get_shop_appointments(
    shop_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    # In a real app, verify that current_user is the owner of the shop or a staff member.
    result = await db.execute(
        select(Appointment)
        .options(selectinload(Appointment.services), selectinload(Appointment.staff), selectinload(Appointment.customer))
        .where(Appointment.shop_id == shop_id)
        .order_by(Appointment.scheduled_time.asc(), Appointment.queue_number.asc())
    )
    appointments = result.scalars().all()
    return appointments

@router.put("/{appointment_id}/status", response_model=AppointmentOut)
async def update_appointment_status(
    appointment_id: str,
    status_update: AppointmentUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    result = await db.execute(
        select(Appointment)
        .options(selectinload(Appointment.services))
        .where(Appointment.id == appointment_id)
    )
    appointment = result.scalar_one_or_none()

    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")

    # In a real app, verify that the current user has permission to update the status
    # (e.g. they are the customer cancelling, or the shop owner/staff approving/completing)

    appointment.status = status_update.status
    await db.commit()
    await db.refresh(appointment)

    # Reload to get relationships
    result = await db.execute(
        select(Appointment)
        .options(selectinload(Appointment.services), selectinload(Appointment.staff), selectinload(Appointment.customer))
        .where(Appointment.id == appointment.id)
    )
    appointment_out = result.scalar_one()

    # Broadcast status change
    await manager.broadcast_json(
        str(appointment_out.shop_id),
        {
            "event": "appointment_status_changed",
            "appointment_id": str(appointment_out.id),
            "status": appointment_out.status,
            "queue_number": appointment_out.queue_number,
        }
    )

    return appointment_out
