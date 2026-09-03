"""
Generates a clean, simple, white-background PakTradeX presentation (.pptx)
with easy wording, clean bullet points, and no heavy boxes or dark backgrounds.
"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

def create_simple_presentation():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    # Clean, Minimalist Palette
    COLOR_TITLE = RGBColor(15, 23, 42)      # Deep Black / Slate 900
    COLOR_BODY = RGBColor(51, 65, 85)       # Charcoal / Slate 700
    COLOR_MUTED = RGBColor(100, 116, 139)   # Subtle Gray
    COLOR_ACCENT = RGBColor(16, 149, 106)   # PSX Green Accent

    def add_slide_header(slide, slide_num, title, subtitle):
        # Header Box
        header_box = slide.shapes.add_textbox(Inches(1.0), Inches(0.8), Inches(11.3), Inches(1.3))
        tf = header_box.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0

        p_num = tf.paragraphs[0]
        p_num.text = f"SLIDE {slide_num}".upper()
        p_num.font.size = Pt(11)
        p_num.font.bold = True
        p_num.font.color.rgb = COLOR_ACCENT

        p_title = tf.add_paragraph()
        p_title.text = title
        p_title.font.size = Pt(28)
        p_title.font.bold = True
        p_title.font.color.rgb = COLOR_TITLE
        p_title.space_before = Pt(4)

        p_sub = tf.add_paragraph()
        p_sub.text = subtitle
        p_sub.font.size = Pt(14)
        p_sub.font.color.rgb = COLOR_MUTED
        p_sub.space_before = Pt(4)

    # ─────────────────────────────────────────────────────────────
    # SLIDE 1: Title
    # ─────────────────────────────────────────────────────────────
    slide1 = prs.slides.add_slide(prs.slide_layouts[6])
    
    title_box = slide1.shapes.add_textbox(Inches(1.2), Inches(1.8), Inches(10.9), Inches(4.5))
    tf1 = title_box.text_frame
    tf1.word_wrap = True

    p0 = tf1.paragraphs[0]
    p0.text = "PakTradeX"
    p0.font.size = Pt(48)
    p0.font.bold = True
    p0.font.color.rgb = COLOR_ACCENT

    p1 = tf1.add_paragraph()
    p1.text = "Pakistan Stock Exchange (PSX) Mobile Trading App"
    p1.font.size = Pt(24)
    p1.font.bold = True
    p1.font.color.rgb = COLOR_TITLE
    p1.space_before = Pt(12)

    p2 = tf1.add_paragraph()
    p2.text = "A simple, risk-free way for everyday Pakistanis to learn, practice, and trade stocks with real market data."
    p2.font.size = Pt(15)
    p2.font.color.rgb = COLOR_BODY
    p2.space_before = Pt(16)

    p3 = tf1.add_paragraph()
    p3.text = "Built with Flutter & FastAPI  •  Live PSX Data  •  100% Free & Risk-Free"
    p3.font.size = Pt(12)
    p3.font.bold = True
    p3.font.color.rgb = COLOR_MUTED
    p3.space_before = Pt(30)

    # ─────────────────────────────────────────────────────────────
    # SLIDE 2: Problem & Who It Affects
    # ─────────────────────────────────────────────────────────────
    slide2 = prs.slides.add_slide(prs.slide_layouts[6])
    add_slide_header(
        slide2, 
        "01", 
        "The Problem & Who It Affects", 
        "Why most people in Pakistan stay away from the stock market."
    )

    body_box2 = slide2.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf2 = body_box2.text_frame
    tf2.word_wrap = True

    points2 = [
        ("Fear of Losing Money", "Most people want to invest in stocks, but they are afraid of losing their hard-earned money because there is no easy way to practice first."),
        ("Hard to Use Tools", "Current broker applications are confusing, full of complex jargon, and designed only for experts."),
        ("Difficult Account Opening", "Opening a real brokerage account takes days, heavy paperwork, and complex verification."),
        ("Who It Affects", "College students, young professionals, and first-time savers across Pakistan who want to grow their money safely."),
    ]

    for i, (head, text) in enumerate(points2):
        p = tf2.paragraphs[0] if i == 0 else tf2.add_paragraph()
        p.text = f"•  {head}: "
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = COLOR_TITLE
        p.space_before = Pt(16) if i > 0 else Pt(0)

        run = p.add_run()
        run.text = text
        run.font.size = Pt(14)
        run.font.bold = False
        run.font.color.rgb = COLOR_BODY

    # ─────────────────────────────────────────────────────────────
    # SLIDE 3: Solution & Audience
    # ─────────────────────────────────────────────────────────────
    slide3 = prs.slides.add_slide(prs.slide_layouts[6])
    add_slide_header(
        slide3, 
        "02", 
        "Our Solution & Target Audience", 
        "A friendly, mobile-first app designed for beginners and everyday traders."
    )

    body_box3 = slide3.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf3 = body_box3.text_frame
    tf3.word_wrap = True

    points3 = [
        ("Practice Trading for Free", "Users get 1,000,000 PKR virtual balance to buy and sell real PSX stocks without risking a single rupee."),
        ("Real-Time PSX Market Data", "Shows exact live prices, daily gains/losses, and interactive charts for top companies like MCB, UBL, Meezan Bank, Systems Limited, and OGDC."),
        ("Halal / Shariah Filter", "Easily view and trade Islamic Shariah-compliant stocks and track the KMI-30 index."),
        ("Simple Verification & Easy Money Transfers", "Practice 1-time CNIC verification and instant simulated deposits using Raast, JazzCash, and EasyPaisa."),
        ("Target Audience", "Beginners, university students, and everyday Pakistanis looking for an easy entry into the stock market."),
    ]

    for i, (head, text) in enumerate(points3):
        p = tf3.paragraphs[0] if i == 0 else tf3.add_paragraph()
        p.text = f"•  {head}: "
        p.font.size = Pt(13.5)
        p.font.bold = True
        p.font.color.rgb = COLOR_TITLE
        p.space_before = Pt(14) if i > 0 else Pt(0)

        run = p.add_run()
        run.text = text
        run.font.size = Pt(13.5)
        run.font.bold = False
        run.font.color.rgb = COLOR_BODY

    # ─────────────────────────────────────────────────────────────
    # SLIDE 4: Need & Impact
    # ─────────────────────────────────────────────────────────────
    slide4 = prs.slides.add_slide(prs.slide_layouts[6])
    add_slide_header(
        slide4, 
        "03", 
        "The Need & Impact", 
        "Building financial awareness and confidence across the country."
    )

    body_box4 = slide4.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf4 = body_box4.text_frame
    tf4.word_wrap = True

    points4 = [
        ("Fighting Inflation", "Helps citizens learn how to beat inflation by investing in solid Pakistani companies instead of keeping cash idle."),
        ("Learning by Doing", "The fastest way to learn the stock market is by placing real orders on live moving charts."),
        ("More Investors for PSX", "Prepares everyday people with real skills and confidence so they can open real broker accounts in the future."),
        ("National Impact", "Brings financial literacy to millions of mobile users in Pakistan through an easy, accessible tool."),
    ]

    for i, (head, text) in enumerate(points4):
        p = tf4.paragraphs[0] if i == 0 else tf4.add_paragraph()
        p.text = f"•  {head}: "
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = COLOR_TITLE
        p.space_before = Pt(16) if i > 0 else Pt(0)

        run = p.add_run()
        run.text = text
        run.font.size = Pt(14)
        run.font.bold = False
        run.font.color.rgb = COLOR_BODY

    # ─────────────────────────────────────────────────────────────
    # SLIDE 5: Technology & Innovation
    # ─────────────────────────────────────────────────────────────
    slide5 = prs.slides.add_slide(prs.slide_layouts[6])
    add_slide_header(
        slide5, 
        "04", 
        "Technology & Innovation", 
        "Modern tech stack delivering smooth, fast, and real-time performance."
    )

    body_box5 = slide5.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf5 = body_box5.text_frame
    tf5.word_wrap = True

    points5 = [
        ("Flutter Mobile App", "Fast, smooth cross-platform app for Android with instant search, animated price ticks, and clean design."),
        ("FastAPI Python Backend", "High-speed backend server handling live market requests, orders, and user authentication."),
        ("Real PSX Market Engine", "Automatically fetches genuine stock quotes and candlestick charts directly from Yahoo Finance (.KA tickers)."),
        ("AI Market Assistant", "Powered by Google Gemini to answer stock market questions and explain company terms in simple words."),
        ("Zero-Downtime Design", "The app works smoothly both online and offline without ever crashing or showing blank screens."),
    ]

    for i, (head, text) in enumerate(points5):
        p = tf5.paragraphs[0] if i == 0 else tf5.add_paragraph()
        p.text = f"•  {head}: "
        p.font.size = Pt(13.5)
        p.font.bold = True
        p.font.color.rgb = COLOR_TITLE
        p.space_before = Pt(14) if i > 0 else Pt(0)

        run = p.add_run()
        run.text = text
        run.font.size = Pt(13.5)
        run.font.bold = False
        run.font.color.rgb = COLOR_BODY

    # ─────────────────────────────────────────────────────────────
    # SLIDE 6: Feasibility & What We Actually Built
    # ─────────────────────────────────────────────────────────────
    slide6 = prs.slides.add_slide(prs.slide_layouts[6])
    add_slide_header(
        slide6, 
        "05", 
        "Feasibility & What We Have Built", 
        "A 100% completed, fully functional, and tested project ready right now."
    )

    body_box6 = slide6.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf6 = body_box6.text_frame
    tf6.word_wrap = True

    points6 = [
        ("Full Working Android App (APK)", "Ready and compiled APK (53.6 MB) that installs on any Android phone."),
        ("Live Stocks & Search", "31 real PSX stocks with live moving prices, depth charts, and search by name/symbol."),
        ("Real Buy & Sell Trading", "Users can place Market and Limit orders, track portfolio profits, and view order history."),
        ("KYC & Wallet System", "Complete CNIC verification flow and simulated deposits with Raast and JazzCash."),
        ("Tested & Reliable", "18/18 automated tests passed with complete source code published on GitHub."),
    ]

    for i, (head, text) in enumerate(points6):
        p = tf6.paragraphs[0] if i == 0 else tf6.add_paragraph()
        p.text = f"•  {head}: "
        p.font.size = Pt(13.5)
        p.font.bold = True
        p.font.color.rgb = COLOR_TITLE
        p.space_before = Pt(14) if i > 0 else Pt(0)

        run = p.add_run()
        run.text = text
        run.font.size = Pt(13.5)
        run.font.bold = False
        run.font.color.rgb = COLOR_BODY

    output_path = "PakTradeX_Presentation.pptx"
    try:
        prs.save(output_path)
        print(f"Clean white presentation saved successfully to {output_path}")
    except Exception as e:
        alt_path = "PakTradeX_Presentation_v2.pptx"
        prs.save(alt_path)
        print(f"Saved to {alt_path}")

if __name__ == "__main__":
    create_simple_presentation()
