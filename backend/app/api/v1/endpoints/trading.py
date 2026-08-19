from fastapi import APIRouter, HTTPException
from ...schemas.api_schemas import TradeOrderCreate, TradeOrderResponse
import uuid
from datetime import datetime

router = APIRouter()

# In-memory simulated portfolio state
SIMULATED_STATE = {
    "available_cash": 274300.00,
    "holdings": [
        {"symbol": "MCB", "shares": 1200, "avg_price": 290.0},
        {"symbol": "ENGRO", "shares": 800, "avg_price": 440.0},
        {"symbol": "OGDC", "shares": 1500, "avg_price": 295.0},
        {"symbol": "SYS", "shares": 350, "avg_price": 420.0},
    ],
    "orders": []
}

@router.get("/portfolio")
async def get_portfolio():
    return SIMULATED_STATE

@router.post("/orders", response_model=TradeOrderResponse)
async def execute_trade_order(order: TradeOrderCreate):
    total_val = order.quantity * order.price
    fee = max(25.0, min(500.0, total_val * 0.0015))

    if order.side.lower() == "buy":
        grand_total = total_val + fee
        if grand_total > SIMULATED_STATE["available_cash"]:
            raise HTTPException(status_code=400, detail="Insufficient simulated cash balance.")
        SIMULATED_STATE["available_cash"] -= grand_total
    else:
        net_proceeds = total_val - fee
        holding = next((h for h in SIMULATED_STATE["holdings"] if h["symbol"] == order.symbol), None)
        if not holding or holding["shares"] < order.quantity:
            raise HTTPException(status_code=400, detail="Insufficient shares owned to execute sell.")
        SIMULATED_STATE["available_cash"] += net_proceeds

    trade_response = TradeOrderResponse(
        id=f"ord-{uuid.uuid4().hex[:8]}",
        symbol=order.symbol.upper(),
        side=order.side.lower(),
        type=order.type.lower(),
        quantity=order.quantity,
        price=order.price,
        totalValue=total_val,
        fee=fee,
        status="executed",
        createdAt=datetime.now()
    )

    SIMULATED_STATE["orders"].insert(0, trade_response.dict())
    return trade_response

@router.post("/deposit")
async def deposit_funds(amount: float):
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Deposit amount must be greater than zero.")
    SIMULATED_STATE["available_cash"] += amount
    return {"status": "success", "new_balance": SIMULATED_STATE["available_cash"]}
