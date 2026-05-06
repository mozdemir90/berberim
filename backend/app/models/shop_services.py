import uuid
import enum
import datetime
from sqlalchemy import Column, String, Boolean, Enum, DateTime, ForeignKey, Integer, Text, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.session import Base
from app.models.profile import BarberShop

class Staff(Base):
    __tablename__ = "staff"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    shop_id = Column(UUID(as_uuid=True), ForeignKey("barber_shops.id", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    is_available = Column(Boolean, default=True)

    shop = relationship("BarberShop", backref="staff")

class Service(Base):
    __tablename__ = "services"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    shop_id = Column(UUID(as_uuid=True), ForeignKey("barber_shops.id", ondelete="CASCADE"), nullable=False)
    translation_key = Column(String, nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    price = Column(Numeric(10, 2), nullable=False)
    currency = Column(String, default="TRY")

    shop = relationship("BarberShop", back_populates="services")

class Translation(Base):
    __tablename__ = "translations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    lang_code = Column(String, nullable=False)
    key = Column(String, nullable=False)
    value = Column(Text, nullable=False)
