from typing import List, Optional
from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from app.models.appointment import AppointmentType, AppointmentStatus
from app.schemas.shop import ServiceOut, StaffOut
from app.schemas.user import UserOut

class AppointmentCreate(BaseModel):
    shop_id: UUID
    service_ids: List[UUID]
    staff_id: Optional[UUID] = None
    type: AppointmentType
    scheduled_time: Optional[datetime] = None

class AppointmentUpdate(BaseModel):
    status: AppointmentStatus

class AppointmentOut(BaseModel):
    id: UUID
    customer_id: UUID
    shop_id: UUID
    staff_id: Optional[UUID] = None
    type: AppointmentType
    status: AppointmentStatus
    scheduled_time: Optional[datetime] = None
    queue_number: Optional[int] = None
    created_at: datetime
    services: List[ServiceOut] = []
    staff: Optional[StaffOut] = None
    customer: Optional[UserOut] = None

    model_config = ConfigDict(from_attributes=True)
