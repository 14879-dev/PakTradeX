from fastapi import APIRouter, HTTPException, status
from ...schemas.api_schemas import UserRegister, UserLogin, OtpVerify, TokenResponse
import uuid

router = APIRouter()

@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register_user(payload: UserRegister):
    # Simulated registration -> triggers 2FA OTP
    return {
        "status": "otp_sent",
        "message": f"6-digit verification code sent to {payload.email} and {payload.phoneNumber}",
        "email": payload.email
    }

@router.post("/login")
async def login_user(payload: UserLogin):
    if not payload.email or not payload.password:
        raise HTTPException(status_code=400, detail="Invalid credentials provided.")
    return {
        "status": "otp_pending",
        "message": "Please enter the 6-digit OTP sent to your registered device.",
        "email": payload.email
    }

@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(payload: OtpVerify):
    if len(payload.code) != 6:
        raise HTTPException(status_code=400, detail="OTP must be exactly 6 numeric digits.")
    
    return TokenResponse(
        access_token=f"pkx_jwt_{uuid.uuid4().hex}",
        user_id=f"usr-{uuid.uuid4().hex[:8]}",
        email=payload.email,
        full_name="Pakistani Investor"
    )
