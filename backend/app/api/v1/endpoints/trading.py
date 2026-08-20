"""
Trading endpoints — DB-persisted portfolio, holdings, and orders.
"""
import uuid
from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ....core.database import get_db
from ....models.db_models import Portfolio, Holding, TradeOrder, OrderSide, OrderStatus
from ....schemas.api_schemas import TradeOrderCreate, TradeOrderResponse
from ....services.market_data_service import get_quote

router = APIRouter()

DEMO_PORTFOLIO_ID = "demo"
BROKERAGE_RATE = 0.0015
MIN_FEE = 25.0
MAX_FEE = 500.0


async def _ensure_portfolio(db: AsyncSession) -> Portfolio:
    """Get or create the demo portfolio."""
    result = await db.execute(select(Portfolio).where(Portfolio.id == DEMO_PORTFOLIO_ID))
    portfolio = result.scalar_one_or_none()
    if portfolio is None:
        portfolio = Portfolio(id=DEMO_PORTFOLIO_ID, available_cash=1_000_000.0)
        db.add(portfolio)
        await db.commit()
        await db.refresh(portfolio)
    return portfolio


@router.get("/portfolio")
async def get_portfolio(db: AsyncSession = Depends(get_db)):
    """Returns the full demo portfolio with live-priced holdings."""
    portfolio = await _ensure_portfolio(db)

    # Load holdings
    holdings_result = await db.execute(
        select(Holding).where(Holding.portfolio_id == DEMO_PORTFOLIO_ID)
    )
    holdings = holdings_result.scalars().all()

    # Load orders (last 50)
    orders_result = await db.execute(
        select(TradeOrder)
        .where(TradeOrder.portfolio_id == DEMO_PORTFOLIO_ID)
        .order_by(TradeOrder.created_at.desc())
        .limit(50)
    )
    orders = orders_result.scalars().all()

    # Enrich holdings with live prices
    holdings_data = []
    total_invested = 0.0
    total_current_value = 0.0

    for h in holdings:
        quote = await get_quote(h.symbol)
        current_price = quote["price"] if quote else h.avg_buy_price
        invested = h.shares * h.avg_buy_price
        current_val = h.shares * current_price
        pnl = current_val - invested
        pnl_pct = (pnl / invested * 100) if invested > 0 else 0.0

        total_invested += invested
        total_current_value += current_val

        holdings_data.append({
            "symbol": h.symbol,
            "name": h.name,
            "sector": h.sector,
            "shares": h.shares,
            "avg_buy_price": h.avg_buy_price,
            "current_price": current_price,
            "total_invested": round(invested, 2),
            "total_current_value": round(current_val, 2),
            "unrealized_pnl": round(pnl, 2),
            "unrealized_pnl_pct": round(pnl_pct, 2),
            "is_live_price": quote.get("is_live", False) if quote else False,
        })

    total_portfolio_value = portfolio.available_cash + total_current_value
    total_pnl = total_current_value - total_invested

    return {
        "portfolio_id": DEMO_PORTFOLIO_ID,
        "available_cash": round(portfolio.available_cash, 2),
        "total_invested": round(total_invested, 2),
        "total_current_value": round(total_current_value, 2),
        "total_portfolio_value": round(total_portfolio_value, 2),
        "total_pnl": round(total_pnl, 2),
        "total_pnl_pct": round((total_pnl / total_invested * 100) if total_invested > 0 else 0, 2),
        "holdings": holdings_data,
        "orders": [
            {
                "id": o.id,
                "symbol": o.symbol,
                "stock_name": o.stock_name,
                "side": o.side.value,
                "order_type": o.order_type,
                "quantity": o.quantity,
                "price": o.price,
                "total_value": o.total_value,
                "fee": o.fee,
                "status": o.status.value,
                "created_at": o.created_at.isoformat(),
            }
            for o in orders
        ],
    }


@router.post("/orders", response_model=TradeOrderResponse)
async def execute_trade_order(
    order: TradeOrderCreate,
    db: AsyncSession = Depends(get_db),
):
    portfolio = await _ensure_portfolio(db)
    total_val = order.quantity * order.price
    fee = float(max(MIN_FEE, min(MAX_FEE, total_val * BROKERAGE_RATE)))

    if order.side.lower() == "buy":
        grand_total = total_val + fee
        if grand_total > portfolio.available_cash:
            raise HTTPException(
                status_code=400,
                detail=f"Insufficient cash. Need Rs.{grand_total:.2f}, have Rs.{portfolio.available_cash:.2f}",
            )
        portfolio.available_cash -= grand_total

        # Update or create holding
        result = await db.execute(
            select(Holding).where(
                Holding.portfolio_id == DEMO_PORTFOLIO_ID,
                Holding.symbol == order.symbol.upper(),
            )
        )
        holding = result.scalar_one_or_none()
        if holding:
            new_shares = holding.shares + order.quantity
            new_avg = (holding.shares * holding.avg_buy_price + order.quantity * order.price) / new_shares
            holding.shares = new_shares
            holding.avg_buy_price = round(new_avg, 4)
        else:
            holding = Holding(
                portfolio_id=DEMO_PORTFOLIO_ID,
                symbol=order.symbol.upper(),
                name=getattr(order, "stock_name", order.symbol.upper()),
                sector=getattr(order, "sector", ""),
                shares=order.quantity,
                avg_buy_price=order.price,
            )
            db.add(holding)

    else:  # sell
        net_proceeds = total_val - fee
        result = await db.execute(
            select(Holding).where(
                Holding.portfolio_id == DEMO_PORTFOLIO_ID,
                Holding.symbol == order.symbol.upper(),
            )
        )
        holding = result.scalar_one_or_none()
        if not holding or holding.shares < order.quantity:
            owned = holding.shares if holding else 0
            raise HTTPException(
                status_code=400,
                detail=f"Insufficient shares. Own {owned}, selling {order.quantity}.",
            )
        holding.shares -= order.quantity
        if holding.shares == 0:
            await db.delete(holding)
        portfolio.available_cash += net_proceeds

    trade = TradeOrder(
        id=f"ord-{uuid.uuid4().hex[:10]}",
        portfolio_id=DEMO_PORTFOLIO_ID,
        symbol=order.symbol.upper(),
        stock_name=getattr(order, "stock_name", order.symbol.upper()),
        side=OrderSide(order.side.lower()),
        order_type=getattr(order, "type", "market"),
        quantity=order.quantity,
        price=order.price,
        total_value=total_val,
        fee=fee,
        status=OrderStatus.executed,
        created_at=datetime.utcnow(),
    )
    db.add(trade)
    await db.commit()

    return TradeOrderResponse(
        id=trade.id,
        symbol=trade.symbol,
        side=trade.side.value,
        type=trade.order_type,
        quantity=trade.quantity,
        price=trade.price,
        totalValue=total_val,
        fee=fee,
        status="executed",
        createdAt=trade.created_at,
    )


@router.post("/deposit")
async def deposit_funds(
    amount: float,
    db: AsyncSession = Depends(get_db),
):
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Deposit amount must be greater than zero.")
    if amount > 10_000_000:
        raise HTTPException(status_code=400, detail="Maximum single deposit is PKR 10,000,000.")

    portfolio = await _ensure_portfolio(db)
    portfolio.available_cash += amount
    await db.commit()

    return {
        "status": "success",
        "deposited": amount,
        "new_balance": round(portfolio.available_cash, 2),
        "message": f"PKR {amount:,.2f} added to your demo portfolio.",
        "timestamp": datetime.utcnow().isoformat(),
    }


@router.post("/reset")
async def reset_demo_portfolio(db: AsyncSession = Depends(get_db)):
    """Resets the demo portfolio to 1,000,000 PKR cash."""
    portfolio = await _ensure_portfolio(db)

    # Delete all holdings and orders
    holdings = await db.execute(select(Holding).where(Holding.portfolio_id == DEMO_PORTFOLIO_ID))
    for h in holdings.scalars().all():
        await db.delete(h)

    orders = await db.execute(select(TradeOrder).where(TradeOrder.portfolio_id == DEMO_PORTFOLIO_ID))
    for o in orders.scalars().all():
        await db.delete(o)

    portfolio.available_cash = 1_000_000.0
    await db.commit()

    return {"status": "reset", "available_cash": 1_000_000.0, "message": "Demo portfolio reset successfully."}
