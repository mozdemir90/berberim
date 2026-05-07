import uuid
import enum
import datetime
from sqlalchemy import Column, String, Enum, DateTime, ForeignKey, Integer, Text, UniqueConstraint, Table
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.session import Base

class AppointmentType(str, enum.Enum):
    SCHEDULED = "SCHEDULED"
    LIVE_QUEUE = "LIVE_QUEUE"

class AppointmentStatus(str, enum.Enum):
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"

appointment_services = Table(
    "appointment_services",
    Base.metadata,
    Column("appointment_id", UUID(as_uuid=True), ForeignKey("appointments.id", ondelete="CASCADE"), primary_key=True),
    Column("service_id", UUID(as_uuid=True), ForeignKey("services.id", ondelete="CASCADE"), primary_key=True),
)

class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    customer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    shop_id = Column(UUID(as_uuid=True), ForeignKey("barber_shops.id", ondelete="CASCADE"), nullable=False)
    staff_id = Column(UUID(as_uuid=True), ForeignKey("staff.id", ondelete="SET NULL"), nullable=True)

    type = Column(Enum(AppointmentType), nullable=False)
    status = Column(Enum(AppointmentStatus), default=AppointmentStatus.PENDING)
    scheduled_time = Column(DateTime, nullable=True)
    queue_number = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    customer = relationship("User", backref="appointments")
    shop = relationship("BarberShop", backref="appointments")
    staff = relationship("Staff", backref="appointments")
    services = relationship("Service", secondary=appointment_services, backref="appointments")

class Review(Base):
    __tablename__ = "reviews"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    appointment_id = Column(UUID(as_uuid=True), ForeignKey("appointments.id", ondelete="CASCADE"), unique=True, nullable=False)
    customer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    shop_id = Column(UUID(as_uuid=True), ForeignKey("barber_shops.id", ondelete="CASCADE"), nullable=False)
    rating = Column(Integer, nullable=False)
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    appointment = relationship("Appointment", backref="review", uselist=False)
    customer = relationship("User")
    shop = relationship("BarberShop")
