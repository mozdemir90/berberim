from typing import Optional
from pydantic import BaseModel, ConfigDict
from datetime import datetime
from uuid import UUID

class B2BPostBase(BaseModel):
    title: str
    description: str
    price: Optional[float] = None
    category: str

class B2BPostCreate(B2BPostBase):
    pass

class B2BPostUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    category: Optional[str] = None

class B2BPostResponse(B2BPostBase):
    id: int
    shop_id: UUID
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
