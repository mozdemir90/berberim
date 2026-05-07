import uuid
import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, Integer, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.session import Base

class B2BPost(Base):
    __tablename__ = "b2b_posts"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    shop_id = Column(UUID(as_uuid=True), ForeignKey("barber_shops.id", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    price = Column(Float, nullable=True)
    category = Column(String, nullable=False) # "İş İlanı", "İkinci El", "Toptan Malzeme"
    created_at = Column(DateTime, default=func.now())

    shop = relationship("BarberShop", backref="b2b_posts")
