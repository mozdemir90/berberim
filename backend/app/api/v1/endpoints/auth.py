from fastapi import APIRouter

router = APIRouter()

from fastapi.security import OAuth2PasswordRequestForm
from fastapi import Depends
from app.core.security import create_access_token

@router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # Gerçek uygulamada DB'den kullanıcı doğrulanır
    # user = authenticate(db, email=form_data.username, password=form_data.password)
    # if not user:
    #     raise HTTPException(status_code=400, detail="Incorrect email or password")

    access_token = create_access_token(subject="user_id_mock_123")
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/register")
async def register():
    # Yeni kullanıcı kaydı
    return {"message": "User registered successfully"}
