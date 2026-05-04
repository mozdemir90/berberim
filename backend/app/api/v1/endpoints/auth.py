from fastapi import APIRouter

router = APIRouter()

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.core.security import create_access_token, verify_password, get_password_hash
from app.db.session import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserOut, Token

@router.post("/register", response_model=UserOut)
async def register(user_in: UserCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == user_in.email))
    user = result.scalars().first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this username already exists in the system.",
        )
    user = User(
        email=user_in.email,
        password_hash=get_password_hash(user_in.password),
        role=user_in.role,
        phone=user_in.phone
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user

@router.post("/login", response_model=Token)
async def login(db: AsyncSession = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()):
    result = await db.execute(select(User).where(User.email == form_data.username))
    user = result.scalars().first()
    if not user or not user.password_hash or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    elif not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")

    access_token = create_access_token(subject=str(user.id))
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/otp/send")
async def send_otp(phone: str):
    # TODO: Implement real SMS integration here (e.g. Twilio, Netgsm)
    return {"message": f"OTP sent to {phone}"}

@router.post("/otp/verify")
async def verify_otp(phone: str, code: str):
    # TODO: Implement verification logic
    if code == "1234":
        return {"message": "OTP verified successfully"}
    raise HTTPException(status_code=400, detail="Invalid OTP code")

@router.post("/social/google")
async def social_login_google(token: str):
    # TODO: Verify google token and create/login user
    return {"message": "Google login successful", "access_token": "mock_token", "token_type": "bearer"}

@router.post("/social/apple")
async def social_login_apple(token: str):
    # TODO: Verify apple token and create/login user
    return {"message": "Apple login successful", "access_token": "mock_token", "token_type": "bearer"}
