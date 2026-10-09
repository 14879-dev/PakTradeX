"""
Generates a clean, simple 6-slide PowerPoint presentation (.pptx)
following Sir Wahab Khan's exact 5-part pitching framework:
Problem -> Solution -> Impact -> Innovation -> Proof
- Exactly 6 slides
- Simple, easy-to-understand words (no complex jargon)
- Clean white background, no complex diagrams, no extra boxes/containers
- No morph transitions
"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor

def create_simple_deck():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    # Clean, high-readability colors
    COLOR_TITLE = RGBColor(15, 23, 42)      # Dark Slate (Black)
    COLOR_BODY = RGBColor(51, 65, 85)       # Dark Gray
    COLOR_GREEN = RGBColor(16, 149, 106)    # PSX Green Accent
    COLOR_MUTED = RGBColor(100, 116, 139)   # Subtle Gray

    def add_clean_header(slide, step_number, title_text, subtitle_text):
        tb = slide.shapes.add_textbox(Inches(1.0), Inches(0.8), Inches(11.3), Inches(1.3))
        tf = tb.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0

        p_step = tf.paragraphs[0]
        p_step.text = step_number.upper()
        p_step.font.size = Pt(11)
        p_step.font.bold = True
        p_step.font.color.rgb = COLOR_GREEN

        p_title = tf.add_paragraph()
        p_title.text = title_text
        p_title.font.size = Pt(28)
        p_title.font.bold = True
        p_title.font.color.rgb = COLOR_TITLE
        p_title.space_before = Pt(4)

        p_sub = tf.add_paragraph()
        p_sub.text = subtitle_text
        p_sub.font.size = Pt(14)
        p_sub.font.color.rgb = COLOR_MUTED
        p_sub.space_before = Pt(4)

    # ─────────────────────────────────────────────────────────────
    # SLIDE 1: Title
    # ─────────────────────────────────────────────────────────────
    s1 = prs.slides.add_slide(prs.slide_layouts[6])
    tb1 = s1.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(11.3), Inches(4.5))
    tf1 = tb1.text_frame
    tf1.word_wrap = True

    p0 = tf1.paragraphs[0]
    p0.text = "AI NATIONAL HACKATHON PAKISTAN  •  CITY UNIVERSITY"
    p0.font.size = Pt(12)
    p0.font.bold = True
    p0.font.color.rgb = COLOR_GREEN

    p1 = tf1.add_paragraph()
    p1.text = "PakTradeX"
    p1.font.size = Pt(46)
    p1.font.bold = True
    p1.font.color.rgb = COLOR_TITLE
    p1.space_before = Pt(10)

    p2 = tf1.add_paragraph()
    p2.text = "Pakistan Stock Exchange (PSX) Mobile Trading App"
    p2.font.size = Pt(22)
    p2.font.bold = True
    p2.font.color.rgb = COLOR_GREEN
    p2.space_before = Pt(6)

    p3 = tf1.add_paragraph()
    p3.text = "A simple, risk-free mobile app that allows everyday Pakistanis to learn, practice, and trade stocks using real market data and AI guidance."
    p3.font.size = Pt(15)
    p3.font.color.rgb = COLOR_BODY
    p3.space_before = Pt(16)

    p4 = tf1.add_paragraph()
    p4.text = "Pitch Framework: Problem  →  Solution  →  Impact  →  Innovation  →  Proof"
    p4.font.size = Pt(12)
    p4.font.bold = True
    p4.font.color.rgb = COLOR_MUTED
    p4.space_before = Pt(36)

    # ─────────────────────────────────────────────────────────────
    # SLIDE 2: 1. The Problem
    # ─────────────────────────────────────────────────────────────
    s2 = prs.slides.add_slide(prs.slide_layouts[6])
    add_clean_header(s2, "Stage 1", "The Problem & Who It Affects", "Why less than 0.1% of Pakistan's population invests in the stock market.")

    tb2 = s2.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf2 = tb2.text_frame
    tf2.word_wrap = True

    points2 = [
        ("Fear of Losing Money", "Most people want to invest, but they are scared of losing their savings because there is no safe place to practice first."),
        ("Outdated & Confusing Apps", "Current broker applications are slow, full of complicated financial words, and difficult for regular people to use."),
        ("Hard Account Opening", "Opening a real broker account takes days, physical paperwork, and complicated checks."),
        ("Who It Affects", "College students, young job holders, and first-time savers across Pakistan who want to grow their savings but do not know where to start."),
    ]

    for i, (heading, text) in enumerate(points2):
        p = tf2.paragraphs[0] if i == 0 else tf2.add_paragraph()
        p.text = f"•  {heading}: "
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
    # SLIDE 3: 2. The Solution
    # ─────────────────────────────────────────────────────────────
    s3 = prs.slides.add_slide(prs.slide_layouts[6])
    add_clean_header(s3, "Stage 2", "Our Solution & Who It Serves", "A simple, friendly trading platform built for beginners.")

    tb3 = s3.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf3 = tb3.text_frame
    tf3.word_wrap = True

    points3 = [
        ("Practice Trading with Virtual Money", "Users receive 1,000,000 PKR virtual balance to buy and sell stocks with zero financial risk."),
        ("Real Live PSX Prices", "The app streams genuine stock prices and charts for top Pakistani companies (MCB, UBL, Meezan Bank, Systems Limited, OGDC)."),
        ("Halal / Shariah Stocks Filter", "Easily view and trade Islamic Shariah-compliant halal stocks and track the KMI-30 index."),
        ("Easy Verification & Wallets", "Practice simple 1-time CNIC verification and instant simulated deposits using Raast, JazzCash, and EasyPaisa."),
        ("Who It Serves", "Beginners, university students, and smartphone users looking for an easy, risk-free entry into stock investing."),
    ]

    for i, (heading, text) in enumerate(points3):
        p = tf3.paragraphs[0] if i == 0 else tf3.add_paragraph()
        p.text = f"•  {heading}: "
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
    # SLIDE 4: 3. Impact
    # ─────────────────────────────────────────────────────────────
    s4 = prs.slides.add_slide(prs.slide_layouts[6])
    add_clean_header(s4, "Stage 3", "Impact on Target Audience & National Need", "Promoting financial literacy and helping people beat inflation.")

    tb4 = s4.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf4 = tb4.text_frame
    tf4.word_wrap = True

    points4 = [
        ("Beating Inflation", "Helps citizens learn how to protect their money from inflation by investing in strong, dividend-paying Pakistani companies."),
        ("Learning by Doing", "Instead of boring books or lectures, users learn trading skills practically on live moving stock charts."),
        ("Confidence for Real Investing", "Builds real experience and confidence so users can smoothly open real broker accounts in the future."),
        ("Economic Growth for Pakistan", "Brings more domestic investors into the Pakistan Stock Exchange, helping businesses grow and funding the economy."),
    ]

    for i, (heading, text) in enumerate(points4):
        p = tf4.paragraphs[0] if i == 0 else tf4.add_paragraph()
        p.text = f"•  {heading}: "
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
    # SLIDE 5: 4. Innovation & Technology
    # ─────────────────────────────────────────────────────────────
    s5 = prs.slides.add_slide(prs.slide_layouts[6])
    add_clean_header(s5, "Stage 4", "The Innovation & Technology Behind It", "How modern tools and AI solve real user challenges.")

    tb5 = s5.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf5 = tb5.text_frame
    tf5.word_wrap = True

    points5 = [
        ("Mobile App (Flutter)", "Fast and smooth Android app with live green/red price tick animations and easy search."),
        ("High-Speed Backend (FastAPI)", "Python server that handles live stock data, user accounts, and trade orders in milliseconds."),
        ("Real PSX Data Feed", "Automatically pulls authentic stock quotes directly from Yahoo Finance (.KA market tickers)."),
        ("Why AI? (Google Gemini)", "Instead of reading 50-page financial reports full of difficult jargon, users get a 3-bullet summary in simple Urdu or English explaining if a stock is healthy and safe."),
        ("Zero-Downtime Guarantee", "The app works reliably online and offline, ensuring it never crashes or shows a blank screen."),
    ]

    for i, (heading, text) in enumerate(points5):
        p = tf5.paragraphs[0] if i == 0 else tf5.add_paragraph()
        p.text = f"•  {heading}: "
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
    # SLIDE 6: 5. Proof of Implementation
    # ─────────────────────────────────────────────────────────────
    s6 = prs.slides.add_slide(prs.slide_layouts[6])
    add_clean_header(s6, "Stage 5", "Proof & What We Have Actually Built", "A completed, fully tested, and working project ready today.")

    tb6 = s6.shapes.add_textbox(Inches(1.0), Inches(2.4), Inches(11.3), Inches(4.5))
    tf6 = tb6.text_frame
    tf6.word_wrap = True

    points6 = [
        ("Working Android App (APK)", "Fully built 53.6 MB Android release APK that installs and runs smoothly on any mobile device."),
        ("31 Live PSX Stocks", "Shows live moving prices, daily change percentages, and searchable company lists."),
        ("Full Trading Engine", "Users can place Buy and Sell Market and Limit orders with real-time portfolio profit and loss calculations."),
        ("KYC & Pakistani Wallet Rails", "Working 1-time CNIC verification and simulated deposits using Raast, JazzCash, and EasyPaisa."),
        ("100% Tested & Verified", "18 out of 18 automated unit and UI tests passed, with complete source code live on GitHub."),
    ]

    for i, (heading, text) in enumerate(points6):
        p = tf6.paragraphs[0] if i == 0 else tf6.add_paragraph()
        p.text = f"•  {heading}: "
        p.font.size = Pt(13.5)
        p.font.bold = True
        p.font.color.rgb = COLOR_TITLE
        p.space_before = Pt(14) if i > 0 else Pt(0)

        run = p.add_run()
        run.text = text
        run.font.size = Pt(13.5)
        run.font.bold = False
        run.font.color.rgb = COLOR_BODY

    output_path = "PakTradeX_Simple_Pitch_Deck.pptx"
    prs.save(output_path)
    print(f"Simple 6-slide presentation saved to {output_path}")

if __name__ == "__main__":
    create_simple_deck()
