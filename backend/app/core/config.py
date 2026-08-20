from pydantic_settings import BaseSettings
from typing import List, Optional


class Settings(BaseSettings):
    PROJECT_NAME: str = "PakTradeX API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "PAKTRADEX_SECURE_JWT_SECRET_KEY_CHANGE_IN_PRODUCTION"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    DATABASE_URL: str = "sqlite+aiosqlite:///./paktradex.db"
    CORS_ORIGINS: List[str] = ["*"]

    # SMTP Real Email Settings (Gmail / SendGrid / Custom SMTP)
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    EMAILS_FROM_NAME: str = "PakTradeX Security"
    EMAILS_FROM_EMAIL: Optional[str] = None

    class Config:
        case_sensitive = True
        env_file = ".env"
        extra = "allow"


settings = Settings()
