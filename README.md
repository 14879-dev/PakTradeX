# PakTradeX 🇵🇰📈

**Pakistan's Premier Mobile Stock Trading Simulator**  
*Built for Bano Qabil — Real PSX market data, zero real money risk.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110-green?logo=fastapi)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.11-yellow?logo=python)](https://python.org)
[![PSX](https://img.shields.io/badge/Data-PSX%20Live-red)](https://www.psx.com.pk)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

---

## 📱 What is PakTradeX?

PakTradeX is a full-stack mobile trading app for the **Pakistan Stock Exchange (PSX)** built with Flutter + FastAPI. It streams **real live PSX prices** via Yahoo Finance and lets users practice trading, manage portfolios, and learn about the stock market — all without real money.

### Key Features
- 🔴 **Live PSX Data** — Real prices via Yahoo Finance (`.KA` tickers), refreshed every 5 minutes
- 📊 **Interactive Charts** — OHLCV candlestick + sparkline charts for all stocks
- 💹 **KSE-100 / KSE-30 / KMI-30** — Real index tracking
- 🏦 **Full KYC Flow** — CNIC verification + OTP + Bank binding (one-time)
- 💰 **Demo & Real Modes** — Practice with virtual funds, upgrade to real after KYC
- 💳 **Deposit / Withdrawal** — Raast, IBFT, JazzCash, EasyPaisa integration
- 🤖 **AI Copilot** — Gemini-powered market insights
- 📰 **Financial News** — Live market news aggregation
- 🔍 **Smart Search** — Search and filter all PSX stocks
- 🌙 **Dark Mode** — Premium glassmorphism UI

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter 3.x (Dart) |
| State Management | Riverpod |
| Navigation | GoRouter |
| Backend API | FastAPI (Python 3.11) |
| Database | SQLite (dev) / PostgreSQL (prod) |
| Market Data | yfinance (Yahoo Finance PSX `.KA` tickers) |
| AI | Google Gemini API |
| Auth | JWT + bcrypt |
| Cloud | Render.com (free tier) |

---

## 🚀 Quick Start

### Option A — Run Locally (Development)

#### Prerequisites
- [Flutter SDK 3.x](https://flutter.dev/docs/get-started/install)
- Python 3.11+
- Git

#### 1. Clone the repo
```bash
git clone https://github.com/14879-dev/PakTradeX.git
cd PakTradeX
```

#### 2. Set up the backend
```bash
cd backend
cp .env.example .env
# Edit .env with your values (Gemini API key, SMTP credentials)
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The backend will be running at `http://localhost:8000`.  
API docs available at `http://localhost:8000/docs`.

#### 3. Run the Flutter app
```bash
cd ..   # back to PakTradeX root
flutter pub get
flutter run
```

> **Device testing:** If running on a physical Android device over Wi-Fi, update the API URL in [`lib/core/config/app_config.dart`](lib/core/config/app_config.dart):
> ```dart
> defaultValue: 'http://YOUR_PC_IP:8000/api/v1',
> ```

---

### Option B — One-Click Cloud Deploy (Render.com)

The backend is pre-configured for [Render.com](https://render.com) free tier.

1. Fork this repo on GitHub
2. Go to [render.com](https://render.com) → **New** → **Blueprint**
3. Connect your forked GitHub repo
4. Render auto-detects `render.yaml` and deploys the backend
5. Add these environment variables in Render dashboard:
   - `GEMINI_API_KEY` — from [aistudio.google.com](https://aistudio.google.com/app/apikey)
   - `SECRET_KEY` — any random 32-char string
   - `SMTP_USER` / `SMTP_PASSWORD` — Gmail App Password for OTP emails
6. Copy the Render URL (e.g. `https://paktradex-api.onrender.com`)
7. Update [`lib/core/config/app_config.dart`](lib/core/config/app_config.dart):
   ```dart
   defaultValue: 'https://paktradex-api.onrender.com/api/v1',
   ```
8. Rebuild and install the Flutter app:
   ```bash
   flutter build apk --release
   ```

---

### Option C — Railway Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template)

1. Fork this repo
2. Go to [railway.app](https://railway.app) → **New Project** → **Deploy from GitHub repo**
3. Select your fork — Railway auto-detects `railway.json`
4. Add environment variables (same as Render above)
5. Copy the Railway URL and update `app_config.dart`

---

## 📂 Project Structure

```
PakTradeX/
├── lib/                          # Flutter app
│   ├── app/                      # Theme, routing, providers
│   │   ├── theme/                # Colors, typography, spacing
│   │   └── router/               # GoRouter config
│   ├── core/                     # Shared widgets, config, utilities
│   │   ├── config/app_config.dart # API URL & app constants
│   │   └── widgets/              # Reusable UI components
│   └── features/                 # Feature modules
│       ├── auth/                 # Login, signup, OTP, forgot password
│       ├── home/                 # Home screen, KSE index cards
│       ├── markets/              # Live PSX stock market
│       ├── trading/              # Buy/sell orders, order book
│       ├── portfolio/            # Holdings, deposit, withdrawal
│       ├── profile/              # KYC, account switcher
│       ├── stock_details/        # Stock chart & detail view
│       ├── news/                 # Financial news feed
│       ├── ai/                   # AI Copilot (Gemini)
│       └── watchlist/            # Favorite stocks
├── backend/                      # FastAPI Python backend
│   ├── app/
│   │   ├── api/v1/endpoints/     # REST API routes
│   │   ├── models/               # Database models
│   │   ├── services/             # Business logic
│   │   │   └── market_data_service.py  # Real PSX data via yfinance
│   │   └── main.py               # FastAPI app entry point
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
├── render.yaml                   # Render.com deployment config
├── railway.json                  # Railway deployment config
└── README.md
```

---

## 🔑 Environment Variables

Copy `backend/.env.example` to `backend/.env` and fill in:

| Variable | Description | Required |
|----------|-------------|----------|
| `GEMINI_API_KEY` | Google AI Studio API key | ✅ Yes |
| `SECRET_KEY` | JWT signing secret (any random string) | ✅ Yes |
| `DATABASE_URL` | SQLite or PostgreSQL URL | ✅ Yes |
| `SMTP_HOST` | Email host (smtp.gmail.com) | Optional |
| `SMTP_USER` | Gmail address for OTP emails | Optional |
| `SMTP_PASSWORD` | Gmail App Password | Optional |

> **Tip:** The app works without SMTP — OTPs are printed to the server console during development.

---

## 📊 Live PSX Data

PakTradeX fetches **real Pakistan Stock Exchange prices** from Yahoo Finance:

| PSX Symbol | Yahoo Ticker | Example Price |
|-----------|-------------|---------------|
| MCB | MCB.KA | Rs. 405 |
| UBL | UBL.KA | Rs. 447 |
| MEBL | MEBL.KA | Rs. 568 |
| HBL | HBL.KA | Rs. 317 |
| OGDC | OGDC.KA | Rs. 332 |
| FFC | FFC.KA | Rs. 552 |
| ... | ... | ... |

Data refreshes every **5 minutes**. Between refreshes, micro-tick movements (±0.3%) keep the UI live.

---

## 🔌 API Endpoints

Once the backend is running, visit `http://localhost:8000/docs` for full Swagger UI.

Key endpoints:
- `GET /api/v1/market/overview` — All PSX stock quotes + KSE-100
- `GET /api/v1/market/quote/{symbol}` — Single stock real-time quote
- `GET /api/v1/market/ohlcv/{symbol}?timeframe=1M` — Chart history
- `GET /api/v1/market/orderbook/{symbol}` — Live order book
- `POST /api/v1/auth/register` — User registration
- `POST /api/v1/auth/login` — JWT login
- `POST /api/v1/trading/order` — Place buy/sell order

---

## 🎓 About — Bano Qabil Project

This project was built as part of **Bano Qabil** — a skills development initiative in Pakistan. It demonstrates:

- Full-stack mobile app development
- Real-time financial data integration
- RESTful API design with FastAPI
- Flutter state management with Riverpod
- JWT authentication & security
- Cloud deployment (Render / Railway)

---

## 🛠️ Development Notes

- **Android Device**: Enable Developer Options → Wireless Debugging, then `adb connect DEVICE_IP:5555`
- **Backend hot reload**: Use `--reload` flag only in development
- **OTP in dev**: Check server console logs for OTP codes (no SMTP needed)
- **Demo mode**: Works fully offline — no KYC required
- **Real mode**: Requires KYC completion in Profile screen

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

*Made with ❤️ in Pakistan 🇵🇰*
