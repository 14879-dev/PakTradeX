"""
Market Data API endpoints — live PSX real-time streaming data & moving tickers.
"""
from fastapi import APIRouter
from ....services import market_data_service as mds

router = APIRouter()


@router.get("/overview")
async def market_overview():
    """KSE-100 index level, movers, and live market state."""
    return await mds.get_live_market_stream()


@router.get("/live-stream")
async def live_stream():
    """Live streaming endpoint with moving prices and tick deltas."""
    return await mds.get_live_market_stream()


@router.get("/stocks")
async def get_all_stocks(sector: str = None, search: str = None):
    """Returns all 30+ PSX stocks with live moving prices."""
    stream = await mds.get_live_market_stream()
    stocks = stream["stocks"]
    if sector and sector.lower() != "all":
        stocks = [s for s in stocks if sector.lower() in s["sector"].lower()]
    if search:
        s_lower = search.lower()
        stocks = [s for s in stocks if s_lower in s["symbol"].lower() or s_lower in s["name"].lower()]
    return {
        "stocks": stocks,
        "count": len(stocks),
        "timestamp": stream["timestamp"],
    }


@router.get("/quote/{symbol}")
async def stock_quote(symbol: str):
    """Real-time quote for a single PSX stock."""
    return await mds.get_quote(symbol)


@router.get("/orderbook/{symbol}")
async def get_orderbook(symbol: str):
    """Dynamic real-time moving order book depth."""
    return await mds.get_live_orderbook(symbol)


@router.get("/history/{symbol}")
async def stock_history(symbol: str, timeframe: str = "1M"):
    """OHLCV candlestick chart history for a PSX stock."""
    candles = await mds.get_ohlcv_history(symbol, timeframe)
    return {
        "symbol": symbol.upper(),
        "timeframe": timeframe.upper(),
        "candles": candles,
        "count": len(candles),
    }
