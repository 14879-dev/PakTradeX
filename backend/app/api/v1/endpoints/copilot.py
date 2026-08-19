from fastapi import APIRouter
from ...schemas.api_schemas import CopilotQuery, CopilotResponse
import uuid

router = APIRouter()

@router.post("/query", response_model=CopilotResponse)
async def query_ai_copilot(query: CopilotQuery):
    q_lower = query.prompt.lower()
    
    if "mcb" in q_lower:
        return CopilotResponse(
            id=f"ai-{uuid.uuid4().hex[:8]}",
            text="MCB Bank Limited demonstrates industry-leading cost-to-income efficiency, high CASA ratio (70%+), and strong quarterly dividend coverage. P/E is 5.4x vs Sector Avg 6.2x.",
            confidenceScore=0.96,
            sentiment="bullish",
            citations=["MCB Annual Report 2024", "SBP Banking Review"],
            actionPrompts=["Analyze MCB vs MEBL", "View MCB Order Book"],
            relatedStockSymbol="MCB"
        )
    elif "dividend" in q_lower or "yield" in q_lower:
        return CopilotResponse(
            id=f"ai-{uuid.uuid4().hex[:8]}",
            text="Top PSX dividend champions include HUBC (~15.1%), MCB (~12.8%), OGDC (~11.2%), and ENGRO (~9.5%). High yield should be confirmed with healthy operating cash flows.",
            confidenceScore=0.95,
            sentiment="bullish",
            citations=["PSX Dividend Database", "MUFAP Analysis"],
            actionPrompts=["Analyze HUBC", "Analyze OGDC"]
        )
    elif "urdu" in q_lower:
        return CopilotResponse(
            id=f"ai-{uuid.uuid4().hex[:8]}",
            text="پی/ای ریشو (P/E Ratio) کمپنی کے منافع اور شیئر کی قیمت کے درمیان تعلق کو ظاہر کرتا ہے۔ مناسب P/E ریشو والے حصص سرمایہ کاری کے لیے پرکشش سمجھے جاتے ہیں۔",
            confidenceScore=0.98,
            sentiment="informative",
            citations=["SECP Jamapunji Financial Literacy Guide"],
            actionPrompts=["Explain Dividends in Urdu", "Explain Stop Loss in Urdu"]
        )
    else:
        return CopilotResponse(
            id=f"ai-{uuid.uuid4().hex[:8]}",
            text="Pakistan Stock Exchange (KSE-100) continues to be supported by positive institutional mutual fund inflows and expectations of single-digit inflation.",
            confidenceScore=0.92,
            sentiment="neutral",
            citations=["PSX Daily Report", "SBP Monetary Policy Release"],
            actionPrompts=["Analyze Banking Sector", "Analyze IT Sector"]
        )
