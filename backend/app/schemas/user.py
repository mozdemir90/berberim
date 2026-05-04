from typing import Optional
from pydantic import BaseModel, EmailStr
from app.models.user import UserRole

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    role: UserRole = UserRole.BARBER
    phone: Optional[str] = None

from uuid import UUID

class UserOut(BaseModel):
    id: UUID
    email: Optional[EmailStr]
    role: UserRole
    phone: Optional[str]

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str
