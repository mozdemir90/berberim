from typing import List, Optional
from pydantic import BaseModel
from uuid import UUID

class ServiceBase(BaseModel):
    translation_key: str
    duration_minutes: int
    price: float
    currency: str = "TRY"

class ServiceCreate(ServiceBase):
    pass

class ServiceOut(ServiceBase):
    id: UUID
    shop_id: UUID

    class Config:
        from_attributes = True

class ShopBase(BaseModel):
    name: str
    description: Optional[str] = None
    address: str
    latitude: float
    longitude: float
    is_open: bool = True

class ShopCreate(ShopBase):
    pass

class ShopUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    is_open: Optional[bool] = None

class ShopOut(ShopBase):
    id: UUID
    owner_id: UUID
    average_rating: float
    services: List[ServiceOut] = []

    class Config:
        from_attributes = True
