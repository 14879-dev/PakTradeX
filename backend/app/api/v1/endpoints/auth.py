"""
Real JWT Authentication Endpoints for PakTradeX.
Stores users in SQLite (dev) / PostgreSQL (prod) with bcrypt passwords.
Issues HS256 JWT tokens valid for 7 days.
"""
import uuid
import random
from fastapi import APIRouter, HTTPException, status, Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional

from ....core.database import get_db
from ....core.security import hash_password, verify_password, create_access_token, decode_token
from ....models.db_models import User, Base
from ....schemas.api_schemas import UserRegister, UserLogin, OtpVerify, TokenResponse

router = APIRouter()

# In-memory OTP store: {email: otp_code}  (use Redis in production)
_pending_otps: dict[str, str] = {}


def _gen_pak_trade_id() -> str:
    """Generate unique PTX-XXXXXX identifier."""
    return f"PTX-{random.randint(100000, 999999)}"


def _gen_otp() -> str:
    return str(random.randint(100000, 999999))


# ── Register ─────────────────────────────────────────────────────────
@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register_user(payload: UserRegister, db: AsyncSession = Depends(get_db)):
    # Check email uniqueness
    result = await db.execute(select(User).where(User.email == payload.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists."
        )

    # Generate & store OTP (simulated SMS send)
    otp = _gen_otp()
    _pending_otps[payload.email] = otp
    print(f"[AUTH] OTP for {payload.email}: {otp}")  # In prod: send via Twilio/Jazz

    # Create user (unverified) — store in DB immediately
    user = User(
        id=str(uuid.uuid4()),
        full_name=payload.fullName,
        email=payload.email,
        phone_number=payload.phoneNumber,
        hashed_password=hash_password(payload.password),
        pak_trade_id=_gen_pak_trade_id(),
        is_verified=0,
        kyc_status="none",
        demo_balance=1_000_000.0,
        real_balance=0.0,
    )
    db.add(user)
    await db.commit()

    return {
        "status": "otp_sent",
        "message": f"6-digit verification code sent to {payload.email}",
        "email": payload.email,
        # Return OTP in dev mode so the app can auto-fill it
        "dev_otp": otp,
    }


# ── Login ─────────────────────────────────────────────────────────────
@router.post("/login")
async def login_user(payload: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == payload.email))
    user: Optional[User] = result.scalar_one_or_none()

    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password."
        )

    # Generate OTP for 2FA
    otp = _gen_otp()
    _pending_otps[payload.email] = otp
    print(f"[AUTH] Login OTP for {payload.email}: {otp}")

    return {
        "status": "otp_pending",
        "message": "Please enter the 6-digit OTP sent to your registered device.",
        "email": payload.email,
        "dev_otp": otp,
    }


# ── Verify OTP → issue JWT ────────────────────────────────────────────
@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(payload: OtpVerify, db: AsyncSession = Depends(get_db)):
    stored_otp = _pending_otps.get(payload.email)

    if not stored_otp or payload.code != stored_otp:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP. Please request a new code."
        )

    # Mark user as verified
    result = await db.execute(select(User).where(User.email == payload.email))
    user: Optional[User] = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    user.is_verified = 1
    await db.commit()

    # Clear used OTP
    _pending_otps.pop(payload.email, None)

    # Issue JWT
    token = create_access_token({"sub": user.id, "email": user.email})

    return TokenResponse(
        access_token=token,
        user_id=user.id,
        email=user.email,
        full_name=user.full_name,
        pak_trade_id=user.pak_trade_id,
        demo_balance=user.demo_balance,
        real_balance=user.real_balance,
        kyc_status=user.kyc_status,
    )


# ── Get Current User (validate token) ────────────────────────────────
@router.get("/me")
async def get_me(
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header.")

    token = authorization.split(" ", 1)[1]
    payload = decode_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Token is invalid or expired.")

    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user: Optional[User] = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    return {
        "user_id": user.id,
        "email": user.email,
        "full_name": user.full_name,
        "phone_number": user.phone_number,
        "pak_trade_id": user.pak_trade_id,
        "is_verified": bool(user.is_verified),
        "kyc_status": user.kyc_status,
        "demo_balance": user.demo_balance,
        "real_balance": user.real_balance,
        "created_at": user.created_at.isoformat(),
    }


# ── Forgot Password (request reset OTP) ──────────────────────────────
@router.post("/forgot-password")
async def forgot_password(email: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    # Always return success to prevent email enumeration
    if user:
        otp = _gen_otp()
        _pending_otps[f"reset:{email}"] = otp
        print(f"[AUTH] Password reset OTP for {email}: {otp}")

    return {
        "status": "reset_sent",
        "message": "If this email is registered, a reset code has been sent.",
        "dev_otp": _pending_otps.get(f"reset:{email}", "N/A"),
    }
