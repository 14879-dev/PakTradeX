"""
Email dispatch service for PakTradeX authentic OTP delivery.
Supports standard SMTP (Gmail, SendGrid, Mailgun, Amazon SES, or custom SMTP server).
"""
import logging
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from ..core.config import settings

logger = logging.getLogger("paktradex.email")


def send_otp_email(to_email: str, otp_code: str, user_name: str = "Valued Investor") -> bool:
    """
    Sends authentic 6-digit OTP verification email with PakTradeX brand styling.
    """
    subject = f"🔐 Your PakTradeX Verification Code: {otp_code}"
    
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #F7FAFC; margin: 0; padding: 20px; }}
            .card {{ max-width: 520px; margin: 0 auto; background: #FFFFFF; border-radius: 16px; padding: 32px; box-shadow: 0 4px 16px rgba(0,0,0,0.06); border: 1px solid #E2E8F0; }}
            .brand {{ font-size: 22px; font-weight: 900; color: #1E3A8A; margin-bottom: 20px; display: flex; align-items: center; }}
            .otp-box {{ background: #EFF6FF; border: 2px dashed #3B82F6; border-radius: 12px; padding: 18px; text-align: center; margin: 24px 0; }}
            .otp-code {{ font-size: 36px; font-weight: 900; letter-spacing: 8px; color: #1D4ED8; margin: 0; }}
            .footer {{ font-size: 12px; color: #718096; text-align: center; margin-top: 24px; border-top: 1px solid #E2E8F0; padding-top: 16px; }}
        </style>
    </head>
    <body>
        <div class="card">
            <div class="brand">
                <span>📈 PakTradeX</span>
            </div>
            <h2 style="color: #1A202C; margin-top: 0;">Verify Your Email Address</h2>
            <p style="color: #4A5568; font-size: 15px; line-height: 1.5;">
                Hello <strong>{user_name}</strong>,<br><br>
                Thank you for joining <strong>PakTradeX</strong> — Pakistan's Next-Gen Stock Trading & Investment Platform.
                Please use the following 6-digit authentication code to verify your account:
            </p>
            <div class="otp-box">
                <div class="otp-code">{otp_code}</div>
            </div>
            <p style="color: #718096; font-size: 13px;">
                ⏱ This code is valid for <strong>10 minutes</strong>. Never share this code with anyone.
            </p>
            <div class="footer">
                © 2026 PakTradeX Pakistan Stock Exchange Trading. All rights reserved.<br>
                SECP & CDC Regulated Rails Simulation Platform
            </div>
        </div>
    </body>
    </html>
    """

    if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
        logger.warning(
            f"[EMAIL SERVICE] SMTP not configured in .env. Code for {to_email} is: {otp_code}. "
            f"To send real emails, set SMTP_USER and SMTP_PASSWORD in backend/.env"
        )
        return False

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = f"{settings.EMAILS_FROM_NAME} <{settings.EMAILS_FROM_EMAIL or settings.SMTP_USER}>"
        msg["To"] = to_email
        msg.attach(MIMEText(html_content, "html"))

        if settings.SMTP_PORT == 465:
            server = smtplib.SMTP_SSL(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10)
        else:
            server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10)
            server.starttls()

        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
        server.sendmail(settings.EMAILS_FROM_EMAIL or settings.SMTP_USER, [to_email], msg.as_string())
        server.quit()
        logger.info(f"[EMAIL SERVICE] Real OTP email sent successfully to {to_email}")
        return True
    except Exception as e:
        logger.error(f"[EMAIL SERVICE] Failed to send email to {to_email}: {e}")
        return False
