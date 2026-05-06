from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.api import deps
from app.db.session import get_db
from app.models.profile import BarberShop
from app.models.shop_services import Service
from app.schemas.shop import ShopCreate, ShopUpdate, ShopOut, ServiceCreate, ServiceOut

router = APIRouter()

@router.get("/", response_model=List[ShopOut])
async def list_shops(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    search: Optional[str] = None
):
    query = select(BarberShop).options(selectinload(BarberShop.services))
    if search:
        query = query.where(BarberShop.name.ilike(f"%{search}%"))
    query = query.offset(skip).limit(limit)
    result = await db.execute(query)
    shops = result.scalars().all()
    return shops

@router.post("/", response_model=ShopOut)
async def create_shop(
    shop_in: ShopCreate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(deps.get_current_active_user)
):
    from app.models.user import UserRole
    if getattr(current_user, "role", None) != UserRole.BARBER:
        raise HTTPException(status_code=403, detail="Yalnızca berberler dükkan oluşturabilir.")

    shop = BarberShop(
        owner_id=current_user.id,
        name=shop_in.name,
        description=shop_in.description,
        address=shop_in.address,
        latitude=shop_in.latitude,
        longitude=shop_in.longitude,
        is_open=shop_in.is_open
    )
    db.add(shop)
    await db.commit()
    await db.refresh(shop)
    return shop

@router.get("/my", response_model=ShopOut)
async def get_my_shop(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(deps.get_current_active_user)
):
    query = select(BarberShop).options(selectinload(BarberShop.services)).where(BarberShop.owner_id == current_user.id)
    result = await db.execute(query)
    shop = result.scalars().first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found for current user")
    return shop

@router.put("/{shop_id}", response_model=ShopOut)
async def update_shop(
    shop_id: str,
    shop_in: ShopUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(deps.get_current_active_user)
):
    query = select(BarberShop).options(selectinload(BarberShop.services)).where(BarberShop.id == shop_id)
    result = await db.execute(query)
    shop = result.scalars().first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found")
    if str(shop.owner_id) != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not enough permissions")

    update_data = shop_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(shop, field, value)

    await db.commit()
    await db.refresh(shop)
    return shop

@router.post("/{shop_id}/services", response_model=ServiceOut)
async def add_service(
    shop_id: str,
    service_in: ServiceCreate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(deps.get_current_active_user)
):
    query = select(BarberShop).where(BarberShop.id == shop_id)
    result = await db.execute(query)
    shop = result.scalars().first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found")
    if str(shop.owner_id) != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not enough permissions")

    service = Service(
        shop_id=shop.id,
        translation_key=service_in.translation_key,
        duration_minutes=service_in.duration_minutes,
        price=service_in.price,
        currency=service_in.currency
    )
    db.add(service)
    await db.commit()
    await db.refresh(service)
    return service
