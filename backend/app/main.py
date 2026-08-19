from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from dotenv import load_dotenv

# Load .env file before anything else
load_dotenv()

from .core.config import settings
from .core.database import engine
from .models.db_models import Base
from .api.v1.api import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create all DB tables on startup."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("[PakTradeX] Database tables initialized.")
    yield
    # Cleanup on shutdown
    await engine.dispose()


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    description=(
        "PakTradeX — AI-Powered Pakistan Stock Exchange (PSX) Trading Platform API. "
        "Provides real-time market data, portfolio management, and Gemini AI Copilot."
    ),
    lifespan=lifespan,
)

# CORS — allow mobile app and web clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "healthy",
        "service": "PakTradeX API",
        "version": settings.VERSION,
        "market": "PSX (Pakistan Stock Exchange)",
        "data_source": "Yahoo Finance (yfinance)",
        "ai": "Google Gemini 2.0 Flash",
    }
