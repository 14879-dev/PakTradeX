from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from ....schemas.api_schemas import StockQuoteSchema, OrderBookSchema, OrderBookLevel

router = APIRouter()

MOCK_STOCKS = [
    StockQuoteSchema(
        symbol="MCB",
        name="MCB Bank Limited",
        sector="Commercial Banks",
        price=322.40,
        change=6.75,
        changePercent=2.14,
        volume=4.8,
        marketCap=382.5,
        peRatio=5.4,
        dividendYield=12.8,
        sparkline=[315.0, 317.0, 318.5, 320.0, 321.2, 322.4],
    ),
    StockQuoteSchema(
        symbol="ENGRO",
        name="Engro Corporation",
        sector="Fertilizer",
        price=481.20,
        change=5.80,
        changePercent=1.22,
        volume=2.1,
        marketCap=258.4,
        peRatio=6.8,
        dividendYield=9.5,
        sparkline=[475.0, 476.5, 479.0, 478.0, 480.5, 481.2],
    ),
    StockQuoteSchema(
        symbol="OGDC",
        name="Oil & Gas Development Co.",
        sector="Oil & Gas",
        price=287.50,
        change=-2.30,
        changePercent=-0.80,
        volume=6.2,
        marketCap=618.0,
        peRatio=4.2,
        dividendYield=11.2,
        sparkline=[290.0, 289.0, 288.5, 287.5],
    ),
    StockQuoteSchema(
        symbol="SYS",
        name="Systems Limited",
        sector="Technology",
        price=462.90,
        change=14.50,
        changePercent=3.23,
        volume=3.4,
        marketCap=134.2,
        peRatio=18.2,
        dividendYield=2.4,
        sparkline=[448.0, 452.0, 456.0, 459.0, 462.9],
    ),
    StockQuoteSchema(
        symbol="LUCK",
        name="Lucky Cement Limited",
        sector="Cement",
        price=654.30,
        change=2.75,
        changePercent=0.42,
        volume=1.6,
        marketCap=205.1,
        peRatio=7.1,
        dividendYield=6.2,
        sparkline=[651.0, 652.0, 653.5, 654.3],
    ),
]

@router.get("/indices")
async def get_indices():
    return [
        {
            "symbol": "KSE-100",
            "name": "PSX Benchmark Index",
            "points": 78420.50,
            "changePoints": 684.20,
            "changePercent": 0.88,
            "high": 78650.00,
            "low": 77920.10,
            "status": "Market Open"
        },
        {
            "symbol": "KSE-30",
            "name": "Top 30 Market Cap Index",
            "points": 24890.30,
            "changePoints": 312.40,
            "changePercent": 1.27,
            "high": 24950.00,
            "low": 24600.00,
            "status": "Market Open"
        },
        {
            "symbol": "KMI-30",
            "name": "Islamic Shariah Index",
            "points": 128450.00,
            "changePoints": -420.10,
            "changePercent": -0.33,
            "high": 129100.00,
            "low": 128200.00,
            "status": "Market Open"
        },
    ]

@router.get("/stocks", response_model=List[StockQuoteSchema])
async def get_stocks(
    sector: Optional[str] = Query(None, description="Filter by sector"),
    search: Optional[str] = Query(None, description="Search symbol or company name")
):
    results = MOCK_STOCKS
    if sector and sector.lower() != "all":
        results = [s for s in results if sector.lower() in s.sector.lower()]
    if search:
        s_lower = search.lower()
        results = [s for s in results if s_lower in s.symbol.lower() or s_lower in s.name.lower()]
    return results

@router.get("/stocks/{symbol}", response_model=StockQuoteSchema)
async def get_stock_detail(symbol: str):
    stock = next((s for s in MOCK_STOCKS if s.symbol.upper() == symbol.upper()), None)
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found on PSX.")
    return stock

@router.get("/stocks/{symbol}/orderbook", response_model=OrderBookSchema)
async def get_orderbook(symbol: str):
    stock = next((s for s in MOCK_STOCKS if s.symbol.upper() == symbol.upper()), None)
    base_price = stock.price if stock else 300.0

    return OrderBookSchema(
        symbol=symbol.upper(),
        bids=[
            OrderBookLevel(price=base_price - 0.20, volume=4500, ordersCount=8),
            OrderBookLevel(price=base_price - 0.50, volume=8200, ordersCount=14),
            OrderBookLevel(price=base_price - 0.80, volume=6100, ordersCount=10),
            OrderBookLevel(price=base_price - 1.20, volume=12400, ordersCount=19),
        ],
        asks=[
            OrderBookLevel(price=base_price + 0.20, volume=3200, ordersCount=6),
            OrderBookLevel(price=base_price + 0.50, volume=7100, ordersCount=12),
            OrderBookLevel(price=base_price + 0.90, volume=5400, ordersCount=9),
            OrderBookLevel(price=base_price + 1.30, volume=10200, ordersCount=17),
        ]
    )
