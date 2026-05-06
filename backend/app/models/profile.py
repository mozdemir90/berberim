import uuid
import enum
import datetime
from sqlalchemy import Column, String, Boolean, Enum, DateTime, ForeignKey, Integer, Float, Text, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.session import Base
from app.models.user import User

class ProviderType(str, enum.Enum):
    GOOGLE = "GOOGLE"
    APPLE = "APPLE"

class AuthProvider(Base):
    __tablename__ = "auth_providers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    provider = Column(Enum(ProviderType), nullable=False)
    provider_id = Column(String, unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User", backref="auth_providers")

class CustomerProfile(Base):
    __tablename__ = "customer_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    loyalty_points = Column(Integer, default=0)
    avatar_url = Column(String, nullable=True)

    user = relationship("User", backref="customer_profile", uselist=False)

class BarberShop(Base):
    __tablename__ = "barber_shops"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    address = Column(Text, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    average_rating = Column(Float, default=0.0)
    is_open = Column(Boolean, default=True)

    owner = relationship("User", back_populates="barber_shops")
    services = relationship("Service", back_populates="shop", cascade="all, delete-orphan")
