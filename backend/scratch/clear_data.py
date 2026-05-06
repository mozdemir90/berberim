import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

DATABASE_URL = "postgresql+asyncpg://postgres:@localhost:5432/berber_db"

async def clear_data():
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        # Truncate all data tables
        await session.execute(text("TRUNCATE TABLE appointments, services, staff, barber_shops CASCADE;"))
        await session.commit()
    
    await engine.dispose()
    print("Database cleared successfully (shops, services, staff, appointments).")

if __name__ == "__main__":
    asyncio.run(clear_data())
