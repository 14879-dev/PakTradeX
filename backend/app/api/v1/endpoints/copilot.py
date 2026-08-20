"""
AI Copilot endpoint — powered by Gemini 2.0 Flash with live PSX market context.
"""
import re
import uuid
from fastapi import APIRouter
from ....schemas.api_schemas import CopilotQuery, CopilotResponse
from ....services import gemini_service

router = APIRouter()

# Extract a stock symbol from the user prompt (e.g. "analyze MCB" → "MCB")
_SYMBOLS = {"MCB", "ENGRO", "OGDC", "SYS", "HBL", "LUCK", "PSO", "PPL", "FFC", "UBL",
            "BAHL", "MEBL", "ATRL", "HUBC", "MARI", "KAPCO"}


def _extract_symbol(prompt: str) -> str | None:
    words = re.split(r"\W+", prompt.upper())
    for word in words:
        if word in _SYMBOLS:
            return word
    return None


@router.post("/query", response_model=CopilotResponse)
async def query_ai_copilot(query: CopilotQuery):
    """Query the Gemini-powered AI Copilot with live market context injection."""
    symbol = _extract_symbol(query.prompt)

    result = await gemini_service.chat(
        user_message=query.prompt,
        symbol=symbol,
    )

    return CopilotResponse(
        id=f"ai-{uuid.uuid4().hex[:8]}",
        text=result.get("response", ""),
        confidenceScore=float(result.get("confidence", 7.0)) / 10.0,
        sentiment=result.get("sentiment", "neutral"),
        citations=result.get("sources", ["Gemini AI", "PSX Data"]),
        actionPrompts=_build_action_prompts(symbol, query.prompt),
        relatedStockSymbol=symbol,
    )


def _build_action_prompts(symbol: str | None, prompt: str) -> list[str]:
    prompts = []
    if symbol:
        prompts.append(f"Show {symbol} chart")
        prompts.append(f"Compare {symbol} vs sector")
    if "shariah" not in prompt.lower():
        prompts.append("Is this Shariah compliant?")
    if "dividend" not in prompt.lower():
        prompts.append("What is the dividend yield?")
    return prompts[:4]
