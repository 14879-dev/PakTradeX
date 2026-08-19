# PakTradeX Backend Launcher
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting PakTradeX FastAPI Backend    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Set-Location -Path "$PSScriptRoot\..\backend"

if (-not (Test-Path ".env")) {
    Write-Host "Creating .env from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
}

Write-Host "Installing/Verifying Python dependencies..." -ForegroundColor Green
pip install -r requirements.txt

Write-Host "Starting FastAPI Server on http://0.0.0.0:8000..." -ForegroundColor Green
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
