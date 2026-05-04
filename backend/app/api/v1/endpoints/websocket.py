from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import Dict, List

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
        if shop_id in self.active_connections:
            self.active_connections[shop_id].remove(websocket)

    async def broadcast_queue_update(self, shop_id: str, message: str):
        if shop_id in self.active_connections:
            for connection in self.active_connections[shop_id]:
                await connection.send_text(message)

manager = ConnectionManager()

@router.websocket("/queue/{shop_id}")
async def websocket_endpoint(websocket: WebSocket, shop_id: str):
    await manager.connect(websocket, shop_id)
    try:
        while True:
            data = await websocket.receive_text()
            # Gerçekte sadece admin/berber sıra atlatır, bu demo amaçlıdır.
            await manager.broadcast_queue_update(shop_id, f"Kuyruk güncellendi: {data}")
    except WebSocketDisconnect:
        manager.disconnect(websocket, shop_id)
