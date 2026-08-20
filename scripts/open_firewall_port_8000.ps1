# Run this script as Administrator to allow port 8000 through Windows Firewall
# Right-click this file → "Run with PowerShell" → Allow UAC prompt

$ruleName = "PakTradeX Backend Port 8000"
$existing = netsh advfirewall firewall show rule name=$ruleName 2>&1

if ($LASTEXITCODE -ne 0) {
    netsh advfirewall firewall add rule `
        name=$ruleName `
        dir=in `
        action=allow `
        protocol=TCP `
        localport=8000
    Write-Host "✅ Firewall rule added: Port 8000 now open for LAN access" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Firewall rule already exists for port 8000" -ForegroundColor Cyan
}

# Also check if Python is bound correctly
Write-Host ""
Write-Host "Testing backend connection..." -ForegroundColor Yellow
$result = Test-NetConnection -ComputerName 192.168.1.16 -Port 8000 -InformationLevel Quiet
if ($result) {
    Write-Host "✅ Port 8000 is now reachable from the network" -ForegroundColor Green
} else {
    Write-Host "❌ Still not reachable - make sure uvicorn is running" -ForegroundColor Red
    Write-Host "   Run: cd D:\Flutter\PakTradeX\backend" -ForegroundColor Yellow
    Write-Host "   Then: python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to close..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
