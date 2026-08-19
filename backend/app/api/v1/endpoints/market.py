"""
Market Data API endpoints — real PSX data from yfinance.
"""
from fastapi import APIRouter
from ...services import market_data_service as mds

router = APIRouter()


@router.get("/overview")
async def market_overview():
    """KSE-100 index level and top movers (live from Yahoo Finance)."""
    return await mds.get_market_overview()


@router.get("/quote/{symbol}")
async def stock_quote(symbol: str):
    """Real-time quote for a single PSX stock."""
    data = await mds.get_quote(symbol)
    if data is None:
        return {"error": f"Symbol {symbol} not found", "symbol": symbol}
    return data


@router.get("/quotes")
async def bulk_quotes(symbols: str = "MCB,ENGRO,OGDC,SYS,HBL,LUCK,PSO"):
    """Comma-separated list of symbols → bulk quote response."""
    sym_list = [s.strip() for s in symbols.split(",") if s.strip()]
    import asyncio
    results = await asyncio.gather(*[mds.get_quote(s) for s in sym_list], return_exceptions=True)
    return {
        "quotes": [r for r in results if isinstance(r, dict)],
        "requested": len(sym_list),
    }


@router.get("/history/{symbol}")
async def stock_history(symbol: str, timeframe: str = "1M"):
    """
    OHLCV history for a PSX stock.
    timeframe: 1D | 1W | 1M | 3M | 1Y | ALL
    """
    candles = await mds.get_ohlcv_history(symbol, timeframe)
    return {
        "symbol": symbol.upper(),
        "timeframe": timeframe.upper(),
        "candles": candles,
        "count": len(candles),
    }
