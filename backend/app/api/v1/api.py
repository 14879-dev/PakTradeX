from fastapi import APIRouter
from .endpoints import auth, markets, trading, copilot, news

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(markets.router, prefix="/markets", tags=["PSX Markets"])
api_router.include_router(trading.router, prefix="/trading", tags=["Simulated Trading"])
api_router.include_router(copilot.router, prefix="/copilot", tags=["AI Copilot"])
api_router.include_router(news.router, prefix="/news", tags=["Financial News"])
