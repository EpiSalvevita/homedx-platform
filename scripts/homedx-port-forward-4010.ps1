#Requires -RunAsAdministrator
# homeDX: refresh Windows portproxy 4000 -> current WSL IP:4010 (Nest often binds 4010 when 4000 is taken).
$ErrorActionPreference = 'Stop'

$wslLine = (& wsl.exe hostname -I 2>$null)
if (-not $wslLine) {
    Write-Host "Error: Could not read WSL IP." -ForegroundColor Red
    exit 1
}
$wslIp = ($wslLine.Trim() -split '\s+')[0]
if ($wslIp -notmatch '^\d{1,3}(\.\d{1,3}){3}$') {
    Write-Host "Error: Unexpected WSL IP: $wslIp" -ForegroundColor Red
    exit 1
}

$connectPort = 4010
Write-Host "WSL IP: $wslIp -> connect port $connectPort" -ForegroundColor Cyan

foreach ($listen in @('0.0.0.0', '127.0.0.1')) {
    netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=$listen 2>$null | Out-Null
    $p = Start-Process -FilePath netsh.exe -ArgumentList @(
        'interface', 'portproxy', 'add', 'v4tov4',
        'listenport=4000', "listenaddress=$listen",
        "connectport=$connectPort", "connectaddress=$wslIp"
    ) -Wait -NoNewWindow -PassThru
    if ($p.ExitCode -ne 0) {
        Write-Host "netsh add ($listen`:4000) failed exit $($p.ExitCode)" -ForegroundColor Red
        exit $p.ExitCode
    }
}

Remove-NetFirewallRule -DisplayName 'homeDX Backend 4000' -ErrorAction SilentlyContinue | Out-Null
New-NetFirewallRule -DisplayName 'homeDX Backend 4000' -Direction Inbound -Protocol TCP -LocalPort 4000 -Action Allow -Profile Domain,Private,Public | Out-Null

Write-Host "Port proxy: Windows :4000 -> ${wslIp}:${connectPort}" -ForegroundColor Green
netsh interface portproxy show all

$log = Join-Path $env:TEMP 'homedx-port-forward-result.txt'
"OK $(Get-Date -Format o) wsl=$wslIp connect=$connectPort" | Set-Content -Path $log -Encoding utf8
