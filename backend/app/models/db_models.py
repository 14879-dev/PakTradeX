"""
SQLAlchemy Database Models for PakTradeX
Uses SQLite in development, PostgreSQL in production.
"""
from datetime import datetime
from sqlalchemy import Column, String, Float, Integer, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import DeclarativeBase, relationship
import enum


class Base(DeclarativeBase):
    pass


class User(Base):
    """Registered PakTradeX user with JWT auth."""
    __tablename__ = "users"

    id = Column(String, primary_key=True)           # UUID
    full_name = Column(String(100), nullable=False)
    email = Column(String(200), unique=True, nullable=False, index=True)
    phone_number = Column(String(20), nullable=True)
    hashed_password = Column(String, nullable=False)
    pak_trade_id = Column(String(20), unique=True, nullable=False)  # PTX-XXXXXX
    is_verified = Column(Integer, default=0)        # 0=unverified, 1=verified
    kyc_status = Column(String(20), default="none") # none|pending|verified
    demo_balance = Column(Float, default=1_000_000.0)
    real_balance = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class OrderSide(str, enum.Enum):
    buy = "buy"
    sell = "sell"


class OrderStatus(str, enum.Enum):
    pending = "pending"
    executed = "executed"
    cancelled = "cancelled"


class Portfolio(Base):
    """Single demo portfolio per session (keyed by session_id)."""
    __tablename__ = "portfolios"

    id = Column(String, primary_key=True, default="demo")
    available_cash = Column(Float, default=1_000_000.0, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    holdings = relationship("Holding", back_populates="portfolio", cascade="all, delete-orphan")
    orders = relationship("TradeOrder", back_populates="portfolio", cascade="all, delete-orphan")


class Holding(Base):
    """A position held in a portfolio."""
    __tablename__ = "holdings"

    id = Column(Integer, primary_key=True, autoincrement=True)
    portfolio_id = Column(String, ForeignKey("portfolios.id"), nullable=False)
    symbol = Column(String(20), nullable=False)
    name = Column(String(100), nullable=False, default="")
    sector = Column(String(100), nullable=False, default="")
    shares = Column(Integer, nullable=False, default=0)
    avg_buy_price = Column(Float, nullable=False, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    portfolio = relationship("Portfolio", back_populates="holdings")


class TradeOrder(Base):
    """An executed trade order."""
    __tablename__ = "trade_orders"

    id = Column(String, primary_key=True)
    portfolio_id = Column(String, ForeignKey("portfolios.id"), nullable=False)
    symbol = Column(String(20), nullable=False)
    stock_name = Column(String(100), nullable=False, default="")
    side = Column(SAEnum(OrderSide), nullable=False)
    order_type = Column(String(20), nullable=False, default="market")
    quantity = Column(Integer, nullable=False)
    price = Column(Float, nullable=False)
    total_value = Column(Float, nullable=False)
    fee = Column(Float, nullable=False)
    status = Column(SAEnum(OrderStatus), nullable=False, default=OrderStatus.executed)
    created_at = Column(DateTime, default=datetime.utcnow)

    portfolio = relationship("Portfolio", back_populates="orders")
