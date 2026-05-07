from fastapi import APIRouter
from app.api.v1.endpoints import auth, users, websocket, shops, appointments, b2b_posts

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(shops.router, prefix="/shops", tags=["shops"])
api_router.include_router(websocket.router, prefix="/ws", tags=["websocket"])
api_router.include_router(appointments.router, prefix="/appointments", tags=["appointments"])
api_router.include_router(b2b_posts.router, prefix="/b2b/posts", tags=["B2B Network"])
