# 🇵🇰 PakTradeX — AI-Powered Pakistan Capital Market Trading Platform

> **"Invest Smarter. Trade Simpler."**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**PakTradeX** is a modern, AI-powered mobile investment and simulated trading ecosystem designed for the **Pakistan Stock Exchange (PSX)**. Built with a **White + Blue** fintech visual design language, rigorous state management, and an integrated bilingual AI Financial Copilot (English & Urdu).

---

## 🌟 Core Feature Suite

### 1. 📊 Real-Time Market Intelligence
- **Benchmark Indices**: Track **KSE-100**, **KSE-30**, and **KMI-30 (Islamic Shariah Index)** with live point changes, high/low intraday ranges, and sparklines.
- **PSX Screener**: Sector-wise filtering across Commercial Banks, Fertilizer, Oil & Gas (E&P), Technology, Cement, and Power.
- **Interactive FlChart**: 6 interactive timeframes (`1D`, `1W`, `1M`, `3M`, `1Y`, `ALL`) with price touch tooltips and gradient volume fill.
- **Market Depth (Order Book)**: Real-time visual Bid/Ask volume queues with spread ratios and depth indicators.

### 2. ⚡ Simulated Trading Engine
- **Risk-Free Execution**: Practice with **Rs. 1,000,000** simulated demo cash.
- **Order Placement**: Market & Limit orders, quick position percentage selectors (`25%`, `50%`, `75%`, `Max`).
- **Transparent Fee Structure**: Automatic calculation of brokerage commission (0.15%, min 25 PKR) adhering to realistic PSX broker standards.
- **Instant Settlement**: Real-time position tracking, weighted average cost accounting, and unrealized/realized P&L calculations.

### 3. 🤖 PakTradeX AI Financial Copilot
- **Bilingual Intelligence**: Answers financial and regulatory queries in English and Urdu (`اردو`).
- **Fundamental Analysis Engine**: Instant P/E, Dividend Yield, ROE, and Debt ratio health checks.
- **Shariah Screening (KMI-30)**: Automated 6-pillar compliance verification.
- **Confidence & Citations**: Every AI response includes verified source citations (SBP, SECP, PSX Rulebook) and confidence metrics.

### 4. 💼 Portfolio & Asset Management
- **Asset Allocation**: Interactive `PieChart` (`fl_chart`) breaking down sector exposure and cash reserves.
- **Holdings Management**: Live unrealized P&L tracking with quick buy/sell shortcuts.
- **Chronological Audit Trail**: Full order history timeline with fee breakdowns and execution timestamps.
- **Simulated Deposit Gateway**: Add funds via Raast (Instant), 1Link 1Bill, or SadaPay/NayaPay.

### 5. 📰 Financial News & Market Catalysts
- **Curated News Feed**: Sentiment tagging (`▲ Bullish`, `▼ Bearish`, `● Neutral`).
- **AI Key Takeaways**: Bulleted strategic summaries on macroeconomic events, circular debt, and SBP monetary policy.
- **Bookmark & Read Later**: Offline-capable saved articles.

### 6. 🔐 Fintech Security & Compliance
- **Two-Factor Authentication (2FA)**: 6-digit OTP verification on login and registration.
- **Biometric Authentication**: Simulated FaceID / Fingerprint unlock.
- **Regulatory Disclosures**: Explicit compliance notice that PakTradeX is an educational simulation platform, not a licensed broker.

---

## 🏗️ Technical Architecture

```
PakTradeX/
├── lib/
│   ├── app/
│   │   ├── app.dart                   # Global MaterialApp & Theme wrapper
│   │   ├── router.dart                # GoRouter with StatefulShellRoute
│   │   └── theme/                     # Fintech Design Tokens (Colors, Spacing, Typography)
│   ├── core/
│   │   ├── network/                   # Dio HTTP Client & Interceptors
│   │   └── widgets/                   # AppCard, PriceChangeBadge, SectionHeader
│   └── features/
│       ├── ai/                        # AI Copilot Screen, Provider, Models & Bubbles
│       ├── auth/                      # Onboarding, Login, Register, OTP Verification
│       ├── home/                      # PSX Dashboard, Gainers/Losers, AiMarketBrief
│       ├── markets/                   # PSX Screener, Sector Filters, Stock Quotes
│       ├── news/                      # News Feed, Sentiment Badges, Detail Views
│       ├── portfolio/                 # Live Portfolio, Sector PieChart, Deposit Modal
│       ├── profile/                   # Account, Security, Biometrics, Disclosures
│       ├── shell/                     # Persistent Bottom Navigation Shell
│       ├── stock_details/             # StockDetailScreen, FlChart, OrderBookWidget
│       ├── trading/                   # TradingNotifier, OrderSheet, Models
│       └── watchlist/                 # Star Watchlist State Notifier
├── backend/                           # FastAPI High-Performance Backend
│   ├── app/
│   │   ├── api/v1/endpoints/          # Auth, Markets, Trading, Copilot, News
│   │   ├── core/config.py             # Settings & JWT Secrets
│   │   ├── schemas/api_schemas.py     # Pydantic Schemas
│   │   └── main.py                    # FastAPI Entrypoint & CORS Middleware
│   ├── Dockerfile
│   └── requirements.txt
├── test/                              # Comprehensive Unit & Widget Test Suite (23+ tests)
├── docker-compose.yml                 # FastAPI + PostgreSQL Compose
└── pubspec.yaml                       # Flutter Dependencies
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.5.0`
- **Dart SDK**: `>= 3.5.0`
- **Python**: `>= 3.10` (for FastAPI Backend)
- **Docker**: (Optional for containerized backend)

### 1. Run Flutter Mobile Application
```bash
# Clone the repository
git clone https://github.com/14879-dev/PakTradeX.git
cd PakTradeX

# Install Flutter dependencies
flutter pub get

# Run test suite
flutter test

# Launch on connected device / emulator
flutter run
```

### 2. Run FastAPI Backend Service
```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start development server
uvicorn app.main:app --reload --port 8000
```
API Documentation will be available at `http://localhost:8000/docs`.

### 3. Run with Docker Compose
```bash
docker-compose up --build -d
```

---

## 🧪 Testing & Quality Assurance

PakTradeX includes an automated test suite covering all critical state management and UI flows:

```bash
flutter analyze
flutter test
```

- ✅ **AuthNotifier**: Guest mode, credentials validation, 6-digit OTP verification, logout.
- ✅ **TradingNotifier**: Buy/Sell order balance validation, brokerage fee deductions, position updates, demo resets.
- ✅ **AiCopilotNotifier**: Prompt routing, confidence score rendering, citations, Urdu localization.
- ✅ **NewsNotifier**: Category filtering, bookmark toggles, sentiment assignment.
- ✅ **Widget Tests**: Splash/Onboarding navigation, OrderHistory, Holdings, Profile switches.

---

## 📜 Regulatory Disclaimer

> **IMPORTANT NOTICE**: PakTradeX is an educational simulated investment research and literacy application. All market data, portfolios, and trade executions are simulated. PakTradeX does not execute live monetary transactions on the Pakistan Stock Exchange (PSX) and is not a licensed broker-dealer under the Securities and Exchange Commission of Pakistan (SECP).

---

## 👥 Contributors & Team
- **14879-dev** (Lead Architect & Core Foundations)
- **kayash1656** (`mdanyal1656@gmail.com`)
- **muhammadabbas5411173-ctrl** (`muhammadabbas5411173@gmail.com`)
- **SyedZohaibShah181** (`syedzohaibshah181@gmail.com`)

---

*Built with ❤️ for Pakistan's financial future.*
