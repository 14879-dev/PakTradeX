"""
PakTradeX Market Data Service
Fetches real PSX (Pakistan Stock Exchange) data via Yahoo Finance.
PSX tickers use the '.KA' suffix on yfinance (e.g. MCB.KA, ENGRO.KA).
"""
import asyncio
import time
from datetime import datetime
from typing import Optional
import yfinance as yf
import pandas as pd

# -----------------------------------------------------------------
# PSX ticker map: display symbol → Yahoo Finance symbol
# -----------------------------------------------------------------
PSX_TICKER_MAP = {
    # Commercial Banks
    "MCB":    "MCB.KA",
    "HBL":    "HBL.KA",
    "UBL":    "UBL.KA",
    "MEBL":   "MEBL.KA",
    "BAFL":   "BAFL.KA",
    "BAHL":   "BAHL.KA",
    # Technology
    "SYS":    "SYS.KA",
    "TRG":    "TRG.KA",
    "NETSOL": "NETSOL.KA",
    # Fertilizer
    "ENGRO":  "ENGRO.KA",
    "FFC":    "FFC.KA",
    "EFERT":  "EFERT.KA",
    # Oil & Gas
    "OGDC":   "OGDC.KA",
    "PPL":    "PPL.KA",
    "PSO":    "PSO.KA",
    "MARI":   "MARI.KA",
    "ATRL":   "ATRL.KA",
    # Cement
    "LUCK":   "LUCK.KA",
    "DGKC":   "DGKC.KA",
    "MLCF":   "MLCF.KA",
    # Power
    "HUBC":   "HUBC.KA",
    "KAPCO":  "KAPCO.KA",
    # Automobiles
    "INDU":   "INDU.KA",
    "HCAR":   "HCAR.KA",
    "PSMC":   "PSMC.KA",
    # Pharma
    "SEARL":  "SEARL.KA",
    "FEROZ":  "FEROZ.KA",
    # Textile
    "NML":    "NML.KA",
    # Insurance
    "JLICL":  "JLICL.KA",
    # Indices
    "^KSE100": "^KSE100",
    "^KSE30":  "^KSE30",
}

PERIOD_MAP = {
    "1D":  ("1d",  "5m"),
    "1W":  ("5d",  "30m"),
    "1M":  ("1mo", "1d"),
    "3M":  ("3mo", "1d"),
    "1Y":  ("1y",  "1wk"),
    "ALL": ("5y",  "1mo"),
}

# Simple TTL cache structure: {key: (data, timestamp)}
_cache: dict[str, tuple] = {}
QUOTE_TTL = 30        # seconds
HISTORY_TTL = 300     # 5 minutes
OVERVIEW_TTL = 60     # 1 minute


def _cache_get(key: str, ttl: int):
    if key in _cache:
        data, ts = _cache[key]
        if time.time() - ts < ttl:
            return data
    return None


def _cache_set(key: str, data):
    _cache[key] = (data, time.time())


def _yf_symbol(symbol: str) -> str:
    return PSX_TICKER_MAP.get(symbol.upper(), f"{symbol.upper()}.KA")


# -----------------------------------------------------------------
# Quote
# -----------------------------------------------------------------
async def get_quote(symbol: str) -> Optional[dict]:
    """Returns current quote for a PSX stock symbol."""
    cache_key = f"quote:{symbol}"
    cached = _cache_get(cache_key, QUOTE_TTL)
    if cached:
        return cached

    try:
        ticker = yf.Ticker(_yf_symbol(symbol))
        info = ticker.fast_info

        # fast_info attributes
        last_price = getattr(info, "last_price", None)
        prev_close = getattr(info, "previous_close", None)
        market_cap = getattr(info, "market_cap", None)
        volume = getattr(info, "three_month_average_volume", None)

        if last_price is None:
            return _mock_quote(symbol)

        change = (last_price - prev_close) if prev_close else 0.0
        change_pct = (change / prev_close * 100) if prev_close else 0.0

        data = {
            "symbol": symbol.upper(),
            "name": _stock_name(symbol),
            "price": round(last_price, 2),
            "previous_close": round(prev_close, 2) if prev_close else None,
            "change": round(change, 2),
            "change_percent": round(change_pct, 2),
            "market_cap": market_cap,
            "volume": volume,
            "currency": "PKR",
            "is_live": True,
            "fetched_at": datetime.utcnow().isoformat(),
        }
        _cache_set(cache_key, data)
        return data

    except Exception as e:
        print(f"[MarketDataService] Quote error for {symbol}: {e}")
        return _mock_quote(symbol)


# -----------------------------------------------------------------
# OHLCV History
# -----------------------------------------------------------------
async def get_ohlcv_history(symbol: str, timeframe: str = "1M") -> list[dict]:
    """Returns OHLCV candles for a given timeframe."""
    cache_key = f"hist:{symbol}:{timeframe}"
    cached = _cache_get(cache_key, HISTORY_TTL)
    if cached:
        return cached

    period, interval = PERIOD_MAP.get(timeframe.upper(), ("1mo", "1d"))

    try:
        ticker = yf.Ticker(_yf_symbol(symbol))
        df: pd.DataFrame = ticker.history(period=period, interval=interval)

        if df.empty:
            return _mock_history(symbol, timeframe)

        candles = []
        for ts, row in df.iterrows():
            candles.append({
                "date": ts.isoformat(),
                "timestamp": int(ts.timestamp()),
                "open":   round(float(row["Open"]),   2),
                "high":   round(float(row["High"]),   2),
                "low":    round(float(row["Low"]),    2),
                "close":  round(float(row["Close"]),  2),
                "volume": int(row["Volume"]) if row["Volume"] else 0,
            })

        _cache_set(cache_key, candles)
        return candles

    except Exception as e:
        print(f"[MarketDataService] History error for {symbol}/{timeframe}: {e}")
        return _mock_history(symbol, timeframe)


# -----------------------------------------------------------------
# Market Overview (KSE-100 + Movers)
# -----------------------------------------------------------------
async def get_market_overview() -> dict:
    """Returns KSE-100 index level and top movers."""
    cached = _cache_get("overview", OVERVIEW_TTL)
    if cached:
        return cached

    try:
        # Fetch KSE-100 index
        kse = yf.Ticker("^KSE100")
        kse_info = kse.fast_info
        kse_price = getattr(kse_info, "last_price", 47832.0)
        kse_prev  = getattr(kse_info, "previous_close", 47600.0)
        kse_change = kse_price - kse_prev if kse_prev else 0
        kse_change_pct = (kse_change / kse_prev * 100) if kse_prev else 0

        # Fetch mover quotes concurrently
        symbols = ["MCB", "ENGRO", "OGDC", "SYS", "HBL", "LUCK", "PSO", "PPL", "FFC", "UBL"]
        quotes = await asyncio.gather(*[get_quote(s) for s in symbols], return_exceptions=True)

        valid_quotes = [q for q in quotes if isinstance(q, dict)]
        gainers = sorted(valid_quotes, key=lambda q: q.get("change_percent", 0), reverse=True)[:5]
        losers  = sorted(valid_quotes, key=lambda q: q.get("change_percent", 0))[:5]

        data = {
            "kse100": {
                "level": round(kse_price, 2),
                "change": round(kse_change, 2),
                "change_percent": round(kse_change_pct, 2),
                "is_live": True,
            },
            "top_gainers": gainers,
            "top_losers": losers,
            "last_updated": datetime.utcnow().isoformat(),
        }
        _cache_set("overview", data)
        return data

    except Exception as e:
        print(f"[MarketDataService] Overview error: {e}")
        return _mock_overview()


# -----------------------------------------------------------------
# Mock fallbacks (used when Yahoo Finance is unreachable)
# -----------------------------------------------------------------
MOCK_PRICES = {
    "MCB": 322.40, "ENGRO": 481.20, "OGDC": 287.50, "SYS": 462.90,
    "HBL": 168.30, "LUCK": 892.10, "PSO": 335.60, "PPL": 124.80,
    "FFC": 143.20, "UBL": 212.50, "BAHL": 86.40, "MEBL": 73.20,
}

MOCK_NAMES = {
    "MCB": "MCB Bank Limited", "ENGRO": "Engro Corporation",
    "OGDC": "Oil & Gas Dev. Co.", "SYS": "Systems Limited",
    "HBL": "Habib Bank Limited", "LUCK": "Lucky Cement",
    "PSO": "Pakistan State Oil", "PPL": "Pakistan Petroleum",
    "FFC": "Fauji Fertilizer", "UBL": "United Bank Limited",
    "BAHL": "Bank Al-Habib", "MEBL": "Meezan Bank",
}


def _stock_name(symbol: str) -> str:
    return MOCK_NAMES.get(symbol.upper(), f"{symbol.upper()} Limited")


def _mock_quote(symbol: str) -> dict:
    price = MOCK_PRICES.get(symbol.upper(), 100.0)
    change = round(price * 0.012, 2)
    return {
        "symbol": symbol.upper(),
        "name": _stock_name(symbol),
        "price": price,
        "previous_close": round(price - change, 2),
        "change": change,
        "change_percent": 1.2,
        "market_cap": None,
        "volume": None,
        "currency": "PKR",
        "is_live": False,
        "fetched_at": datetime.utcnow().isoformat(),
    }


def _mock_history(symbol: str, timeframe: str) -> list[dict]:
    import math
    base = MOCK_PRICES.get(symbol.upper(), 300.0)
    now = datetime.utcnow()
    candles = []
    n = {"1D": 78, "1W": 35, "1M": 22, "3M": 65, "1Y": 52, "ALL": 60}.get(timeframe, 22)
    for i in range(n):
        t = now.timestamp() - (n - i) * 86400
        noise = math.sin(i * 0.4) * base * 0.03 + (i * base * 0.001)
        close = round(base + noise, 2)
        open_ = round(close - base * 0.008, 2)
        candles.append({
            "date": datetime.utcfromtimestamp(t).isoformat(),
            "timestamp": int(t),
            "open": open_, "high": round(close + base * 0.005, 2),
            "low": round(open_ - base * 0.005, 2), "close": close,
            "volume": 500000,
        })
    return candles


def _mock_overview() -> dict:
    return {
        "kse100": {"level": 47832.0, "change": 232.0, "change_percent": 0.49, "is_live": False},
        "top_gainers": [_mock_quote(s) for s in ["SYS", "ENGRO", "LUCK", "MCB", "FFC"]],
        "top_losers":  [_mock_quote(s) for s in ["OGDC", "PSO", "PPL", "UBL", "HBL"]],
        "last_updated": datetime.utcnow().isoformat(),
    }
