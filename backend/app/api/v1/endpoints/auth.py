"""
Real JWT Authentication Endpoints for PakTradeX.
Stores users in SQLite (dev) / PostgreSQL (prod) with bcrypt passwords.
Issues HS256 JWT tokens valid for 7 days.
Dispatches authentic 6-digit OTP verification codes to user emails via SMTP.
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
from ....services.email_service import send_otp_email

router = APIRouter()

# In-memory OTP store: {email: otp_code}
_pending_otps: dict[str, str] = {}


def _gen_pak_trade_id() -> str:
    """Generate unique PTX-XXXXXX identifier."""
    return f"PTX-{random.randint(100000, 999999)}"


def _gen_otp() -> str:
    """Generate 6-digit random verification code."""
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

    # Generate & store OTP
    otp = _gen_otp()
    _pending_otps[payload.email] = otp
    print(f"\n[AUTH EMAIL DISPATCH] Sending OTP {otp} to {payload.email}...")

    # Send real email
    send_otp_email(to_email=payload.email, otp_code=otp, user_name=payload.fullName)

    # Create user (unverified)
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
        "message": f"6-digit authentication code sent to {payload.email}",
        "email": payload.email,
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
    print(f"\n[AUTH EMAIL DISPATCH] Sending Login 2FA OTP {otp} to {payload.email}...")

    # Send real email
    send_otp_email(to_email=payload.email, otp_code=otp, user_name=user.full_name)

    return {
        "status": "otp_pending",
        "message": f"Please enter the 6-digit code sent to {payload.email}",
        "email": payload.email,
    }


# ── Resend OTP ────────────────────────────────────────────────────────
@router.post("/resend-otp")
async def resend_otp(payload: dict, db: AsyncSession = Depends(get_db)):
    email = payload.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Email is required.")

    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    user_name = user.full_name if user else "Investor"

    otp = _gen_otp()
    _pending_otps[email] = otp
    print(f"\n[AUTH EMAIL DISPATCH] Resending OTP {otp} to {email}...")
    send_otp_email(to_email=email, otp_code=otp, user_name=user_name)

    return {
        "status": "otp_sent",
        "message": f"New verification code sent to {email}",
    }


# ── Verify OTP → issue JWT ────────────────────────────────────────────
@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(payload: OtpVerify, db: AsyncSession = Depends(get_db)):
    stored_otp = _pending_otps.get(payload.email)

    if not stored_otp or payload.code != stored_otp:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired verification code. Please check your email or request a new code."
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
    db: AsyncSession = Depends(get_db),
):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token format.")

    token = authorization.split(" ")[1]
    payload = decode_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Token expired or invalid.")

    user_id = payload["sub"]
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
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
    }


# ── Forgot Password ───────────────────────────────────────────────────
@router.post("/forgot-password")
async def forgot_password(payload: dict, db: AsyncSession = Depends(get_db)):
    email = payload.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Email is required.")

    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    if not user:
        # Don't leak whether email exists
        return {"status": "ok", "message": "If an account exists, a reset code was sent."}

    otp = _gen_otp()
    _pending_otps[email] = otp
    print(f"\n[AUTH EMAIL DISPATCH] Password Reset OTP {otp} for {email}...")
    send_otp_email(to_email=email, otp_code=otp, user_name=user.full_name)

    return {"status": "ok", "message": f"Password reset code sent to {email}"}
