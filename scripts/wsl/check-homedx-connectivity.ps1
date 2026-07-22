# Quick checks for phone/emulator -> Windows -> WSL backend (port 4000).
# Run in Windows PowerShell (Admin not required for most checks).
#
# Optional: sync Flutter .env API_BASE_URL to your current Wi-Fi/Ethernet IPv4 (avoids stale 192.168.* after DHCP changes):
# From repo root (Windows PowerShell):
#   .\scripts\wsl\check-homedx-connectivity.ps1 -UpdateMobileEnv

param(
    [switch]$UpdateMobileEnv
)

function Get-PreferredWindowsLanIPv4 {
    $all = @(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -notlike '169.254.*' -and
        $_.InterfaceAlias -notmatch 'Loopback|vEthernet|WSL|Hyper-V|VirtualBox|VMware|Tailscale|ZeroTier'
    })
    if ($all.Count -eq 0) { return $null }
    $wifiEth = $all | Where-Object { $_.InterfaceAlias -match 'Wi-Fi|WiFi|WLAN|Ethernet' } | Select-Object -First 1
    if ($wifiEth) { return $wifiEth.IPAddress }
    $first = $all | Select-Object -First 1
    if ($first) { return $first.IPAddress }
    return $null
}

Write-Host "`n=== Windows LAN IPv4 (use the Wi-Fi/Ethernet your PC actually uses) ===" -ForegroundColor Cyan
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notlike '169.254.*' } |
    Select-Object InterfaceAlias, IPAddress | Format-Table -AutoSize

Write-Host "`n=== WSL2 IP (portproxy should point 4000 here) ===" -ForegroundColor Cyan
wsl -e hostname -I 2>$null

Write-Host "`n=== Port proxy for 4000 ===" -ForegroundColor Cyan
netsh interface portproxy show all

Write-Host "`n=== Test TCP to localhost:4000 on Windows (needs backend up in WSL) ===" -ForegroundColor Cyan
$tnc = Test-NetConnection -ComputerName 127.0.0.1 -Port 4000 -WarningAction SilentlyContinue
$tnc | Select-Object ComputerName, RemotePort, TcpTestSucceeded

Write-Host "`n=== Test HTTP via portproxy (TCP can succeed while HTTP fails on some WSL2 setups) ===" -ForegroundColor Cyan
$probeUrl = 'http://127.0.0.1:4000/gg-homedx-json/gg-api/v1/get-be-status-flags'
try {
    $body = Invoke-RestMethod -Uri $probeUrl -Method Post -ContentType 'application/json' -Body '{}' -TimeoutSec 10
    Write-Host "HTTP OK: $probeUrl" -ForegroundColor Green
    Write-Host ($body | ConvertTo-Json -Compress)
} catch {
    Write-Host "HTTP FAILED to $probeUrl" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "If TcpTestSucceeded was True but HTTP fails: see docs/WSL2_PORT_FORWARDING.md → Troubleshooting (mirrored networking or run Nest on Windows)." -ForegroundColor Yellow
}

$lan = Get-PreferredWindowsLanIPv4
if ($lan) {
    $lanUrl = "http://${lan}:4000/gg-homedx-json/gg-api/v1/get-be-status-flags"
    Write-Host "`n=== Test HTTP to Windows LAN IP (same path as a phone on Wi-Fi) ===" -ForegroundColor Cyan
    try {
        $body2 = Invoke-RestMethod -Uri $lanUrl -Method Post -ContentType 'application/json' -Body '{}' -TimeoutSec 10
        Write-Host "HTTP OK: $lanUrl" -ForegroundColor Green
        Write-Host ($body2 | ConvertTo-Json -Compress)
    } catch {
        Write-Host "HTTP FAILED to $lanUrl" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Write-Host "`nIf TcpTestSucceeded is False: start backend in WSL, rerun scripts\wsl\setup-wsl-port-forward.cmd as Admin.`n" -ForegroundColor Yellow
Write-Host "Phone .env API_BASE_URL must use the Windows IPv4 above (not the WSL IP).`n" -ForegroundColor Yellow

if ($UpdateMobileEnv) {
    $lan = Get-PreferredWindowsLanIPv4
    if (-not $lan) {
        Write-Host "Could not detect a LAN IPv4; not updating .env." -ForegroundColor Red
        exit 1
    }
    $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    $envFile = Join-Path $repoRoot "frontend\mobile\hdx_mobile\.env"
    if (-not (Test-Path $envFile)) {
        Write-Host "Missing file: $envFile" -ForegroundColor Red
        exit 1
    }
    $url = "http://${lan}:4000"
    $lines = Get-Content $envFile
    $found = $false
    $out = foreach ($line in $lines) {
        if ($line -match '^\s*API_BASE_URL=') {
            "API_BASE_URL=$url"
            $found = $true
        } else {
            $line
        }
    }
    if (-not $found) {
        $out = @("API_BASE_URL=$url") + $out
    }
    Set-Content -Path $envFile -Value $out -Encoding utf8
    Write-Host "Updated $envFile -> API_BASE_URL=$url" -ForegroundColor Green
    Write-Host "Rebuild the app: cd frontend\mobile\hdx_mobile && flutter run`n" -ForegroundColor Yellow
}
