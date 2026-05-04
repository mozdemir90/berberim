from typing import List, Union
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "SUPER_SECRET_KEY_FOR_DEV_ONLY"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8

    # DATABASE
    # Testing for sandbox environments using default postgres config if available
    SQLALCHEMY_DATABASE_URI: str = "postgresql+asyncpg://postgres:@localhost:5432/berber_db"

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]

    class Config:
        case_sensitive = True

settings = Settings()
