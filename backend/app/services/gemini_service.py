"""
PakTradeX Gemini AI Service
Wraps Google Generative AI (Gemini 2.0 Flash) with PSX financial context.
"""
import os
from datetime import datetime
from typing import Optional
import google.generativeai as genai

from .market_data_service import get_quote

_model = None

SYSTEM_PROMPT = """You are PakTradeX AI Copilot — an expert financial analyst specializing in the
Pakistan Stock Exchange (PSX), KSE-100, and Pakistani macroeconomics.

You help retail investors in Pakistan understand:
- PSX listed company fundamentals, technicals, and valuation
- Sector analysis (Banking, Oil & Gas, Fertilizer, Technology, Cement, Textile)
- Pakistan's macroeconomic context (PKR, SBP policy rate, inflation, CAD)
- Shariah-compliant (halal) investing under SECP guidelines
- Risk management for PSX investors
- Urdu/English mixed responses when asked in Urdu

IMPORTANT RULES:
1. Always mention that PakTradeX is a DEMO/educational platform — not a licensed broker.
2. Do NOT give specific buy/sell price targets — give general analysis only.
3. Cite the current price provided in context when discussing a specific stock.
4. Confidence level: provide a confidence score 1-10 for your analysis.
5. Keep responses concise (max 250 words) — mobile-friendly.
6. Format with emoji bullets for readability on mobile screens.

Response format (JSON):
{
  "response": "Your analysis text here",
  "confidence": 7.5,
  "sources": ["PSX Data", "Company Annual Report", "SBP Policy"],
  "sentiment": "bullish|bearish|neutral",
  "disclaimer": "For educational purposes only. Not investment advice."
}"""


def _get_model():
    global _model
    if _model is None:
        api_key = os.getenv("GEMINI_API_KEY", "")
        if not api_key:
            return None
        genai.configure(api_key=api_key)
        _model = genai.GenerativeModel(
            model_name="gemini-2.0-flash",
            system_instruction=SYSTEM_PROMPT,
            generation_config=genai.types.GenerationConfig(
                temperature=0.4,
                max_output_tokens=512,
            ),
        )
    return _model


async def chat(user_message: str, symbol: Optional[str] = None) -> dict:
    """Send a message to Gemini with optional live market context."""

    # Build enriched prompt with live market data
    context = ""
    if symbol:
        try:
            quote = await get_quote(symbol)
            if quote:
                context = (
                    f"\n[LIVE MARKET CONTEXT for {symbol}]\n"
                    f"Current Price: PKR {quote['price']}\n"
                    f"Day Change: {quote['change']:+.2f} ({quote['change_percent']:+.2f}%)\n"
                    f"Source: {'Yahoo Finance (Live)' if quote['is_live'] else 'Cached/Estimated'}\n"
                )
        except Exception:
            pass

    model = _get_model()
    if model is None:
        return _fallback_response(user_message, symbol)

    full_prompt = f"{context}\nUser query: {user_message}"

    try:
        response = model.generate_content(full_prompt)
        text = response.text.strip()

        # Try to parse as JSON, else wrap
        import json
        try:
            # Strip markdown code fences if present
            clean = text.replace("```json", "").replace("```", "").strip()
            parsed = json.loads(clean)
            return parsed
        except json.JSONDecodeError:
            return {
                "response": text,
                "confidence": 7.0,
                "sources": ["Gemini AI Analysis"],
                "sentiment": "neutral",
                "disclaimer": "For educational purposes only. Not investment advice.",
            }
    except Exception as e:
        print(f"[GeminiService] Error: {e}")
        return _fallback_response(user_message, symbol)


def _fallback_response(user_message: str, symbol: Optional[str] = None) -> dict:
    """Intelligent canned response when Gemini API unavailable."""
    msg = user_message.lower()
    sym = symbol.upper() if symbol else ""

    if any(w in msg for w in ["analyze", "analysis", "تجزیہ"]):
        response = (
            f"📊 **{sym or 'Stock'} Analysis** (Demo Mode)\n\n"
            "🔹 Fundamentals: Review P/E ratio vs sector average and book value per share.\n"
            "🔹 Technicals: Watch 50-day and 200-day moving averages for trend confirmation.\n"
            "🔹 Macro: Monitor SBP policy rate — banking stocks are rate-sensitive.\n"
            "🔹 Catalyst: Upcoming earnings and dividend announcements drive near-term moves.\n\n"
            "_Set your GEMINI_API_KEY in .env to enable live AI analysis._"
        )
    elif any(w in msg for w in ["shariah", "halal", "islamic", "شریعہ"]):
        response = (
            "🕌 **Shariah-Compliant Investing (PSX)**\n\n"
            "✅ SECP-approved Shariah-compliant stocks follow these screens:\n"
            "🔹 Debt-to-assets ratio below 33%\n"
            "🔹 No primary business in haram sectors (alcohol, gambling, pork, interest-based banking)\n"
            "🔹 Purification of impermissible income portion\n\n"
            "📋 KMI-30 index tracks the 30 most Shariah-compliant PSX companies.\n"
            "Top halal options: Systems Limited (SYS), Lucky Cement (LUCK), Engro (ENGRO)."
        )
    else:
        response = (
            "🤖 **PakTradeX AI Copilot**\n\n"
            f"Your query: *{user_message}*\n\n"
            "I can help you with:\n"
            "🔹 Stock analysis (e.g. 'Analyze MCB')\n"
            "🔹 Sector insights (Banking, Oil & Gas, Tech)\n"
            "🔹 Shariah-compliant investing\n"
            "🔹 Pakistan macro (PKR, SBP rate, inflation)\n"
            "🔹 Portfolio strategy tips\n\n"
            "_Add GEMINI_API_KEY to unlock live AI responses._"
        )

    return {
        "response": response,
        "confidence": 6.5,
        "sources": ["PSX Knowledge Base", "SECP Guidelines"],
        "sentiment": "neutral",
        "disclaimer": "For educational purposes only. Not investment advice.",
    }
