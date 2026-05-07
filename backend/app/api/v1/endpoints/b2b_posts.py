from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional

from app.api.deps import get_db, get_current_active_user
from app.models.user import User, UserRole
from app.models.profile import BarberShop
from app.models.b2b_post import B2BPost
from app.schemas.b2b_post import B2BPostCreate, B2BPostResponse

router = APIRouter()

@router.post("/", response_model=B2BPostResponse, status_code=status.HTTP_201_CREATED)
async def create_b2b_post(
    post_in: B2BPostCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    if current_user.role != UserRole.BARBER:
        raise HTTPException(status_code=403, detail="Only barbers can create B2B posts.")

    # Find the barber's shop
    shop_result = await db.execute(select(BarberShop).where(BarberShop.owner_id == current_user.id))
    shop = shop_result.scalar_one_or_none()

    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found for this user.")

    if post_in.category not in ["İş İlanı", "İkinci El", "Toptan Malzeme"]:
        raise HTTPException(status_code=400, detail="Invalid category.")

    new_post = B2BPost(
        shop_id=shop.id,
        title=post_in.title,
        description=post_in.description,
        price=post_in.price,
        category=post_in.category
    )

    db.add(new_post)
    await db.commit()
    await db.refresh(new_post)
    return new_post

@router.get("/", response_model=List[B2BPostResponse])
async def list_b2b_posts(
    category: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    query = select(B2BPost)
    if category:
        query = query.where(B2BPost.category == category)

    query = query.order_by(B2BPost.created_at.desc())
    result = await db.execute(query)
    posts = result.scalars().all()
    return posts

@router.get("/me", response_model=List[B2BPostResponse])
async def list_my_b2b_posts(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    if current_user.role != UserRole.BARBER:
        raise HTTPException(status_code=403, detail="Only barbers have own posts.")

    # Find the barber's shop
    shop_result = await db.execute(select(BarberShop).where(BarberShop.owner_id == current_user.id))
    shop = shop_result.scalar_one_or_none()

    if not shop:
        return []

    query = select(B2BPost).where(B2BPost.shop_id == shop.id).order_by(B2BPost.created_at.desc())
    result = await db.execute(query)
    posts = result.scalars().all()
    return posts

@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_b2b_post(
    post_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    result = await db.execute(select(B2BPost).where(B2BPost.id == post_id))
    post = result.scalar_one_or_none()

    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    # Check ownership
    shop_result = await db.execute(select(BarberShop).where(BarberShop.owner_id == current_user.id))
    shop = shop_result.scalar_one_or_none()

    if not shop or post.shop_id != shop.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this post")

    await db.delete(post)
    await db.commit()
    return None
