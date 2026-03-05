# homeDX Platform - WSL2 Port Forwarding
# Run as Administrator in PowerShell
# Forwards Windows port 4000 to WSL2 so the mobile app can reach the backend

$ErrorActionPreference = "Stop"

# Get WSL2 IP
$wslIp = (wsl hostname -I 2>$null).Trim().Split()[0]
if (-not $wslIp) {
    Write-Host "Error: Could not get WSL2 IP. Is WSL running?" -ForegroundColor Red
    exit 1
}

Write-Host "WSL2 IP: $wslIp" -ForegroundColor Cyan

# Remove existing rules for port 4000
netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=0.0.0.0 2>$null
netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=127.0.0.1 2>$null

# Add portproxy rules
netsh interface portproxy add v4tov4 listenport=4000 listenaddress=0.0.0.0 connectport=4000 connectaddress=$wslIp
netsh interface portproxy add v4tov4 listenport=4000 listenaddress=127.0.0.1 connectport=4000 connectaddress=$wslIp

Write-Host "Port proxy configured: 4000 -> $wslIp`:4000" -ForegroundColor Green

# Firewall rule (remove existing first)
Remove-NetFirewallRule -DisplayName "homeDX Backend 4000" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "homeDX Backend 4000" -Direction Inbound -Protocol TCP -LocalPort 4000 -Action Allow

Write-Host "Firewall rule added for port 4000" -ForegroundColor Green
Write-Host ""
Write-Host "Done. Use API_BASE_URL=http://<your-windows-lan-ip>:4000 in mobile .env" -ForegroundColor Yellow
