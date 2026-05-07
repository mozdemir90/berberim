import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query
from typing import Dict, List, Any
from jose import jwt, JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.core.config import settings
from app.db.session import get_db
from app.models.user import User

logger = logging.getLogger(__name__)

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, shop_id: str):
        await websocket.accept()
        if shop_id not in self.active_connections:
            self.active_connections[shop_id] = []
        self.active_connections[shop_id].append(websocket)

    def disconnect(self, websocket: WebSocket, shop_id: str):
        if shop_id in self.active_connections and websocket in self.active_connections[shop_id]:
            self.active_connections[shop_id].remove(websocket)
            if not self.active_connections[shop_id]:
                del self.active_connections[shop_id]

    async def broadcast_queue_update(self, shop_id: str, message: str):
        if shop_id in self.active_connections:
            # Create a copy of the list to avoid concurrent modification issues
            for connection in list(self.active_connections[shop_id]):
                try:
                    await connection.send_text(message)
                except Exception as e:
                    logger.error(f"Error sending message to websocket: {e}")
                    self.disconnect(connection, shop_id)

    async def broadcast_json(self, shop_id: str, data: dict):
        if shop_id in self.active_connections:
            for connection in list(self.active_connections[shop_id]):
                try:
                    await connection.send_json(data)
                except Exception as e:
                    logger.error(f"Error sending json to websocket: {e}")
                    self.disconnect(connection, shop_id)

manager = ConnectionManager()

async def get_ws_current_user(
    token: str = Query(...),
    db: AsyncSession = Depends(get_db)
):
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
        user_id: str = payload.get("sub")
        if user_id is None:
            return None
    except JWTError:
        return None

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    return user

@router.websocket("/queue/{shop_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    shop_id: str,
    user: User = Depends(get_ws_current_user)
):
    if user is None:
        await websocket.close(code=1008)
        return

    await manager.connect(websocket, shop_id)
    try:
        while True:
            # We don't necessarily need to receive text from the client for queue updates
            # as it is driven by HTTP endpoints. But we keep the loop alive.
            data = await websocket.receive_text()
            # If the user sends a ping, we can pong back
            # await websocket.send_json({"type": "pong", "data": data})
    except WebSocketDisconnect:
        manager.disconnect(websocket, shop_id)
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        manager.disconnect(websocket, shop_id)
