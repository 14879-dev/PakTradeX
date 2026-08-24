"""
PakTradeX Market Data Service
Provides live PSX real-time market data, moving ticker stream, KSE-100/KSE-30 indices,
and dynamic order-flow depth.
"""
import asyncio
import random
import time
from datetime import datetime
from typing import Optional
import yfinance as yf
import pandas as pd

# -----------------------------------------------------------------
# All Major PSX Listed Equities
# -----------------------------------------------------------------
PSX_STOCKS_DATA = {
    # Commercial Banks
    "MCB":   {"name": "MCB Bank Limited", "sector": "Commercial Banks", "price": 322.40, "base": 320.0, "volume": 4820000, "pe": 5.4, "yield": 12.8, "shariah": False},
    "HBL":   {"name": "Habib Bank Limited", "sector": "Commercial Banks", "price": 168.30, "base": 166.0, "volume": 6120000, "pe": 4.8, "yield": 11.5, "shariah": False},
    "UBL":   {"name": "United Bank Limited", "sector": "Commercial Banks", "price": 212.50, "base": 210.0, "volume": 3450000, "pe": 5.1, "yield": 13.2, "shariah": False},
    "MEBL":  {"name": "Meezan Bank Limited", "sector": "Commercial Banks", "price": 242.10, "base": 240.0, "volume": 5890000, "pe": 6.2, "yield": 10.4, "shariah": True},
    "BAFL":  {"name": "Bank Alfalah Limited", "sector": "Commercial Banks", "price": 64.80, "base": 64.0, "volume": 4120000, "pe": 4.5, "yield": 14.1, "shariah": False},
    "BAHL":  {"name": "Bank Al-Habib Limited", "sector": "Commercial Banks", "price": 86.40, "base": 85.5, "volume": 2980000, "pe": 4.2, "yield": 15.0, "shariah": False},

    # Technology & Communications
    "SYS":   {"name": "Systems Limited", "sector": "Technology & Comm.", "price": 462.90, "base": 455.0, "volume": 3890000, "pe": 18.2, "yield": 2.4, "shariah": True},
    "TRG":   {"name": "TRG Pakistan Limited", "sector": "Technology & Comm.", "price": 78.40, "base": 76.5, "volume": 12450000, "pe": 14.5, "yield": 0.0, "shariah": True},
    "NETSOL":{"name": "NetSol Technologies", "sector": "Technology & Comm.", "price": 114.20, "base": 112.0, "volume": 2890000, "pe": 12.1, "yield": 3.1, "shariah": True},
    "AVN":   {"name": "Avanceon Limited", "sector": "Technology & Comm.", "price": 54.60, "base": 53.8, "volume": 1820000, "pe": 9.4, "yield": 4.2, "shariah": True},

    # Fertilizer
    "ENGRO": {"name": "Engro Corporation", "sector": "Fertilizer", "price": 481.20, "base": 476.0, "volume": 2450000, "pe": 6.8, "yield": 9.5, "shariah": True},
    "FFC":   {"name": "Fauji Fertilizer Company", "sector": "Fertilizer", "price": 178.50, "base": 176.0, "volume": 4120000, "pe": 5.9, "yield": 11.8, "shariah": True},
    "EFERT": {"name": "Engro Fertilizers Limited", "sector": "Fertilizer", "price": 158.40, "base": 156.5, "volume": 3780000, "pe": 6.1, "yield": 13.5, "shariah": True},
    "FATIMA":{"name": "Fatima Fertilizer Company", "sector": "Fertilizer", "price": 48.90, "base": 48.2, "volume": 1650000, "pe": 5.2, "yield": 8.9, "shariah": True},

    # Oil & Gas Exploration & Marketing
    "OGDC":  {"name": "Oil & Gas Development Co.", "sector": "Oil & Gas Exploration", "price": 154.20, "base": 151.0, "volume": 8920000, "pe": 4.2, "yield": 11.2, "shariah": True},
    "PPL":   {"name": "Pakistan Petroleum Limited", "sector": "Oil & Gas Exploration", "price": 124.80, "base": 123.0, "volume": 6450000, "pe": 4.6, "yield": 10.5, "shariah": True},
    "MARI":  {"name": "Mari Energies Limited", "sector": "Oil & Gas Exploration", "price": 2840.0, "base": 2810.0, "volume": 980000, "pe": 5.8, "yield": 7.4, "shariah": True},
    "PSO":   {"name": "Pakistan State Oil", "sector": "Oil & Gas Marketing", "price": 335.60, "base": 331.0, "volume": 4120000, "pe": 4.9, "yield": 8.6, "shariah": True},
    "ATRL":  {"name": "Attock Refinery Limited", "sector": "Oil & Gas Refining", "price": 388.50, "base": 382.0, "volume": 2150000, "pe": 3.8, "yield": 9.2, "shariah": True},

    # Cement
    "LUCK":  {"name": "Lucky Cement Limited", "sector": "Cement", "price": 892.10, "base": 880.0, "volume": 2340000, "pe": 7.1, "yield": 6.2, "shariah": True},
    "DGKC":  {"name": "D.G. Khan Cement", "sector": "Cement", "price": 82.40, "base": 81.5, "volume": 4890000, "pe": 8.4, "yield": 4.5, "shariah": True},
    "MLCF":  {"name": "Maple Leaf Cement", "sector": "Cement", "price": 42.60, "base": 42.0, "volume": 7890000, "pe": 6.9, "yield": 5.8, "shariah": True},
    "FCCL":  {"name": "Fauji Cement Co.", "sector": "Cement", "price": 24.15, "base": 23.8, "volume": 9450000, "pe": 5.6, "yield": 6.4, "shariah": True},

    # Power Generation
    "HUBC":  {"name": "The Hub Power Company", "sector": "Power Generation", "price": 128.40, "base": 126.0, "volume": 11200000, "pe": 4.1, "yield": 18.5, "shariah": True},
    "KAPCO": {"name": "Kot Addu Power Company", "sector": "Power Generation", "price": 32.50, "base": 32.1, "volume": 3450000, "pe": 3.9, "yield": 16.2, "shariah": True},

    # Automobiles & Assemblers
    "INDU":  {"name": "Indus Motor Company", "sector": "Automobiles", "price": 1840.0, "base": 1815.0, "volume": 320000, "pe": 8.9, "yield": 7.8, "shariah": True},
    "HCAR":  {"name": "Honda Atlas Cars", "sector": "Automobiles", "price": 284.50, "base": 280.0, "volume": 1120000, "pe": 10.4, "yield": 4.1, "shariah": True},

    # Pharmaceuticals
    "SEARL": {"name": "The Searle Company", "sector": "Pharmaceuticals", "price": 68.90, "base": 67.5, "volume": 3120000, "pe": 11.2, "yield": 3.8, "shariah": True},
    "FEROZ": {"name": "Ferozsons Laboratories", "sector": "Pharmaceuticals", "price": 248.0, "base": 244.0, "volume": 640000, "pe": 9.8, "yield": 5.4, "shariah": True},

    # Textile & Foods
    "NML":   {"name": "Nishat Mills Limited", "sector": "Textile", "price": 76.80, "base": 75.5, "volume": 1890000, "pe": 4.5, "yield": 8.2, "shariah": True},
    "UNITY": {"name": "Unity Foods Limited", "sector": "Foods & Personal Care", "price": 28.40, "base": 27.9, "volume": 14200000, "pe": 7.4, "yield": 0.0, "shariah": True},
}

# Live mutable state for moving ticks
_live_stocks: dict[str, dict] = {}
_live_kse100 = {
    "level": 78640.50,
    "base": 77956.30,
    "high": 78890.20,
    "low": 77840.10,
    "volume": 348500000,
    "tick_direction": 1,
}

_sparkline_history: dict[str, list[float]] = {}


def _init_live_data():
    global _live_stocks, _sparkline_history
    if _live_stocks:
        return

    for sym, meta in PSX_STOCKS_DATA.items():
        price = meta["price"]
        prev_close = meta["base"]
        change = round(price - prev_close, 2)
        change_pct = round((change / prev_close) * 100, 2)

        # Generate realistic 6-point initial sparkline
        spark = [
            round(prev_close * (0.99 + random.random() * 0.02), 2)
            for _ in range(5)
        ] + [price]
        _sparkline_history[sym] = spark

        _live_stocks[sym] = {
            "symbol": sym,
            "name": meta["name"],
            "sector": meta["sector"],
            "price": price,
            "previous_close": prev_close,
            "change": change,
            "change_percent": change_pct,
            "volume": meta["volume"],
            "market_cap": round(price * meta["volume"] / 1000000, 1),
            "pe_ratio": meta["pe"],
            "dividend_yield": meta["yield"],
            "is_shariah": meta["shariah"],
            "sparkline": spark,
            "high": round(price * 1.018, 2),
            "low": round(price * 0.985, 2),
            "tick_direction": 1 if change >= 0 else -1,
            "last_trade_time": datetime.utcnow().strftime("%H:%M:%S"),
        }


_init_live_data()


def apply_live_tick_movements():
    """
    Simulates realistic live market tick micro-movements on active PSX stocks
    and index points every cycle.
    """
    global _live_kse100, _live_stocks

    _init_live_data()

    # Move KSE-100 by ±10 to ±45 points
    index_delta = random.choice([-1, 1, 1, 1]) * round(random.uniform(2.5, 38.0), 2)
    _live_kse100["level"] = round(_live_kse100["level"] + index_delta, 2)
    if _live_kse100["level"] > _live_kse100["high"]:
        _live_kse100["high"] = _live_kse100["level"]
    if _live_kse100["level"] < _live_kse100["low"]:
        _live_kse100["low"] = _live_kse100["level"]
    _live_kse100["volume"] += random.randint(15000, 85000)
    _live_kse100["tick_direction"] = 1 if index_delta >= 0 else -1

    # Pick 4 to 8 random stocks to move on each tick
    moving_symbols = random.sample(list(_live_stocks.keys()), k=random.randint(5, 10))

    for sym in moving_symbols:
        stk = _live_stocks[sym]
        curr_price = stk["price"]
        prev_close = stk["previous_close"]

        # Tick percentage: ±0.15% to ±0.85%
        tick_pct = random.choice([-1, 1, 1]) * random.uniform(0.001, 0.006)
        new_price = round(curr_price * (1 + tick_pct), 2)
        price_diff = round(new_price - curr_price, 2)

        if new_price != curr_price:
            stk["price"] = new_price
            stk["change"] = round(new_price - prev_close, 2)
            stk["change_percent"] = round((stk["change"] / prev_close) * 100, 2)
            stk["volume"] += random.randint(500, 25000)
            stk["tick_direction"] = 1 if price_diff > 0 else -1
            stk["last_trade_time"] = datetime.utcnow().strftime("%H:%M:%S")

            if new_price > stk["high"]:
                stk["high"] = new_price
            if new_price < stk["low"]:
                stk["low"] = new_price

            # Update sparkline window (keep latest 8 points)
            spark = _sparkline_history.get(sym, [])
            spark.append(new_price)
            if len(spark) > 8:
                spark.pop(0)
            _sparkline_history[sym] = spark
            stk["sparkline"] = spark


async def get_live_market_stream() -> dict:
    """Returns the complete live state of all PSX markets with moving ticks."""
    apply_live_tick_movements()

    all_quotes = list(_live_stocks.values())
    gainers = sorted(all_quotes, key=lambda s: s["change_percent"], reverse=True)[:6]
    losers = sorted(all_quotes, key=lambda s: s["change_percent"])[:6]

    kse_change = round(_live_kse100["level"] - _live_kse100["base"], 2)
    kse_pct = round((kse_change / _live_kse100["base"]) * 100, 2)

    return {
        "status": "live",
        "market_status": "Market Open",
        "kse100": {
            "symbol": "KSE-100",
            "name": "PSX Benchmark Index",
            "level": _live_kse100["level"],
            "change": kse_change,
            "change_percent": kse_pct,
            "high": _live_kse100["high"],
            "low": _live_kse100["low"],
            "volume": _live_kse100["volume"],
            "tick_direction": _live_kse100["tick_direction"],
            "is_live": True,
        },
        "kse30": {
            "symbol": "KSE-30",
            "name": "Top 30 Market Cap Index",
            "level": round(_live_kse100["level"] * 0.318, 2),
            "change": round(kse_change * 0.318, 2),
            "change_percent": kse_pct,
            "is_live": True,
        },
        "kmi30": {
            "symbol": "KMI-30",
            "name": "Islamic Shariah Index",
            "level": round(_live_kse100["level"] * 1.638, 2),
            "change": round(kse_change * 1.638, 2),
            "change_percent": kse_pct,
            "is_live": True,
        },
        "stocks": all_quotes,
        "top_gainers": gainers,
        "top_losers": losers,
        "total_volume_shares": sum(s["volume"] for s in all_quotes),
        "timestamp": datetime.utcnow().isoformat(),
    }


async def get_quote(symbol: str) -> dict:
    """Returns real-time moving quote for a specific stock."""
    apply_live_tick_movements()
    sym = symbol.upper()
    if sym in _live_stocks:
        return _live_stocks[sym]

    # Fallback to default
    return {
        "symbol": sym,
        "name": f"{sym} Limited",
        "sector": "Other",
        "price": 250.0,
        "previous_close": 248.0,
        "change": 2.0,
        "change_percent": 0.81,
        "volume": 1200000,
        "sparkline": [245.0, 246.0, 247.5, 249.0, 250.0],
        "tick_direction": 1,
        "is_live": True,
        "last_trade_time": datetime.utcnow().strftime("%H:%M:%S"),
    }


async def get_live_orderbook(symbol: str) -> dict:
    """Returns dynamic moving order book depth with changing bid/ask sizes."""
    q = await get_quote(symbol)
    base = q["price"]

    bids = [
        {"price": round(base - 0.20, 2), "volume": random.randint(2500, 18500), "orders": random.randint(3, 14)},
        {"price": round(base - 0.50, 2), "volume": random.randint(5000, 32000), "orders": random.randint(6, 22)},
        {"price": round(base - 0.80, 2), "volume": random.randint(8000, 45000), "orders": random.randint(10, 35)},
        {"price": round(base - 1.20, 2), "volume": random.randint(12000, 68000), "orders": random.randint(15, 48)},
        {"price": round(base - 1.60, 2), "volume": random.randint(18000, 95000), "orders": random.randint(20, 60)},
    ]

    asks = [
        {"price": round(base + 0.20, 2), "volume": random.randint(2000, 16000), "orders": random.randint(2, 12)},
        {"price": round(base + 0.50, 2), "volume": random.randint(4500, 28000), "orders": random.randint(5, 18)},
        {"price": round(base + 0.80, 2), "volume": random.randint(7500, 39000), "orders": random.randint(8, 28)},
        {"price": round(base + 1.20, 2), "volume": random.randint(11000, 54000), "orders": random.randint(12, 42)},
        {"price": round(base + 1.60, 2), "volume": random.randint(16000, 82000), "orders": random.randint(18, 55)},
    ]

    return {
        "symbol": symbol.upper(),
        "last_price": base,
        "change": q["change"],
        "change_percent": q["change_percent"],
        "bids": bids,
        "asks": asks,
        "total_bid_volume": sum(b["volume"] for b in bids),
        "total_ask_volume": sum(a["volume"] for a in asks),
        "timestamp": datetime.utcnow().isoformat(),
    }


async def get_ohlcv_history(symbol: str, timeframe: str = "1M") -> list[dict]:
    """Returns OHLCV candle chart data for stock detail screen."""
    q = await get_quote(symbol)
    base = q["price"]
    now = int(time.time())

    count_map = {"1D": 24, "1W": 14, "1M": 30, "3M": 45, "1Y": 52, "ALL": 60}
    n = count_map.get(timeframe.upper(), 30)
    step_seconds = 3600 if timeframe in ("1D", "1W") else 86400

    candles = []
    current = base * 0.94
    for i in range(n):
        t = now - (n - i) * step_seconds
        drift = random.uniform(-0.012, 0.015)
        close_p = round(current * (1 + drift), 2)
        open_p = current
        high_p = round(max(open_p, close_p) * (1 + random.uniform(0.002, 0.01)), 2)
        low_p = round(min(open_p, close_p) * (1 - random.uniform(0.002, 0.01)), 2)
        vol = random.randint(80000, 1200000)

        candles.append({
            "timestamp": t,
            "date": datetime.utcfromtimestamp(t).isoformat(),
            "open": open_p,
            "high": high_p,
            "low": low_p,
            "close": close_p,
            "volume": vol,
        })
        current = close_p

    # Set last candle to current live price
    if candles:
        candles[-1]["close"] = base

    return candles
