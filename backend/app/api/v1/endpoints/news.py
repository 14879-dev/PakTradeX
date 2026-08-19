from fastapi import APIRouter
from typing import List

router = APIRouter()

MOCK_NEWS = [
    {
        "id": "news-1",
        "title": "SBP Monetary Policy Committee Signals Further Interest Rate Easing",
        "source": "Business Recorder",
        "publishedAt": "25m ago",
        "category": "Economy",
        "sentiment": "bullish",
        "readingTimeMinutes": 3,
        "relatedStockSymbol": "MCB",
        "summary": "State Bank of Pakistan notes headline CPI inflation decelerating to single digits, paving the way for further key policy rate cuts."
    },
    {
        "id": "news-2",
        "title": "Energy Circular Debt Settlement Plan Reaches Final Approval Stage",
        "source": "Dawn News Business",
        "publishedAt": "1h ago",
        "category": "Energy",
        "sentiment": "bullish",
        "readingTimeMinutes": 4,
        "relatedStockSymbol": "OGDC",
        "summary": "Ministry of Energy and Finance finalize a structured dividend and cash-settlement mechanism to clear overdue receivables."
    }
]

@router.get("/")
async def get_news(category: str = "All"):
    if category != "All":
        return [n for n in MOCK_NEWS if n["category"].lower() == category.lower()]
    return MOCK_NEWS
