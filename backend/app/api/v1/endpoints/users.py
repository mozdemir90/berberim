from fastapi import APIRouter

router = APIRouter()

from fastapi import Depends
from app.api import deps

@router.get("/me")
async def read_users_me(current_user: dict = Depends(deps.get_current_active_user)):
    return {"message": "Current user profile", "user": current_user}
