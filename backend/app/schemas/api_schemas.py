from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# --- Auth Schemas ---
class UserRegister(BaseModel):
    fullName: str
    email: EmailStr
    phoneNumber: str
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class OtpVerify(BaseModel):
    email: EmailStr
    code: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str
    full_name: str

# --- Market Schemas ---
class StockQuoteSchema(BaseModel):
    symbol: str
    name: str
    sector: str
    price: float
    change: float
    changePercent: float
    volume: float
    marketCap: float
    peRatio: float
    dividendYield: float
    sparkline: List[float]

class OrderBookLevel(BaseModel):
    price: float
    volume: int
    ordersCount: int

class OrderBookSchema(BaseModel):
    symbol: str
    bids: List[OrderBookLevel]
    asks: List[OrderBookLevel]

# --- Trading Schemas ---
class TradeOrderCreate(BaseModel):
    symbol: str
    side: str # "buy" or "sell"
    type: str # "market" or "limit"
    quantity: int
    price: float

class TradeOrderResponse(BaseModel):
    id: str
    symbol: str
    side: str
    type: str
    quantity: int
    price: float
    totalValue: float
    fee: float
    status: str
    createdAt: datetime

# --- AI Copilot Schemas ---
class CopilotQuery(BaseModel):
    prompt: str
    language: Optional[str] = "English"

class CopilotResponse(BaseModel):
    id: str
    text: str
    confidenceScore: float
    sentiment: str
    citations: List[str]
    actionPrompts: List[str]
    relatedStockSymbol: Optional[str] = None
