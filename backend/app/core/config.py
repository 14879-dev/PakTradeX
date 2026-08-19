from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "PakTradeX API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "PAKTRADEX_SECURE_JWT_SECRET_KEY_CHANGE_IN_PRODUCTION"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/paktradex"
    CORS_ORIGINS: list[str] = ["*"]

    class Config:
        case_sensitive = True

settings = Settings()
