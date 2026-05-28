#Requires -RunAsAdministrator
<#
 homeDX Platform - WSL2 port forwarding for backend (TCP 4000).
 Must run elevated: netsh portproxy + Windows Firewall.
 From WSL repo root: ./run-wsl-port-forward-elevated.sh (copies into %TEMP% and triggers UAC)
 (elevated shells often fail to execute scripts from \\wsl$\ UNC roots).
#>
$ErrorActionPreference = 'Stop'

# Prefer eth0 (mirrored networking / single primary NIC); fall back to first hostname -I token.
$wslIp = (& wsl.exe -e /bin/sh -c 'ip -4 -o addr show eth0 2>/dev/null | awk ''{print $4}'' | cut -d/ -f1' 2>$null).Trim()
if (-not $wslIp) {
    $wslLine = (& wsl.exe hostname -I 2>$null)
    if (-not $wslLine) {
        Write-Host "Error: Could not read WSL IP (eth0 or hostname -I). Is WSL running?" -ForegroundColor Red
        exit 1
    }
    $wslIp = ($wslLine.Trim() -split '\s+')[0]
}
if ($wslIp -notmatch '^\d{1,3}(\.\d{1,3}){3}$') {
    Write-Host "Error: Unexpected WSL IP value: $wslIp" -ForegroundColor Red
    exit 1
}

Write-Host "WSL2 IP (connect target): $wslIp" -ForegroundColor Cyan

# Remove stale rules (ignore exit code if missing)
Start-Process -FilePath netsh.exe -ArgumentList @('interface','portproxy','delete','v4tov4','listenport=4000','listenaddress=0.0.0.0') -Wait -NoNewWindow -PassThru | Out-Null
Start-Process -FilePath netsh.exe -ArgumentList @('interface','portproxy','delete','v4tov4','listenport=4000','listenaddress=127.0.0.1') -Wait -NoNewWindow -PassThru | Out-Null

$p1 = Start-Process -FilePath netsh.exe -ArgumentList @('interface','portproxy','add','v4tov4','listenport=4000','listenaddress=0.0.0.0','connectport=4000',"connectaddress=$wslIp") -Wait -NoNewWindow -PassThru
if ($p1.ExitCode -ne 0) {
    Write-Host "netsh add (0.0.0.0:4000) failed with exit $($p1.ExitCode)" -ForegroundColor Red
    exit $p1.ExitCode
}
$p2 = Start-Process -FilePath netsh.exe -ArgumentList @('interface','portproxy','add','v4tov4','listenport=4000','listenaddress=127.0.0.1','connectport=4000',"connectaddress=$wslIp") -Wait -NoNewWindow -PassThru
if ($p2.ExitCode -ne 0) {
    Write-Host "netsh add (127.0.0.1:4000) failed with exit $($p2.ExitCode)" -ForegroundColor Red
    exit $p2.ExitCode
}

Write-Host "Port proxy rules added for 4000 -> ${wslIp}:4000" -ForegroundColor Green

$show = netsh interface portproxy show all
Write-Host ($show)

if ($show -notmatch [regex]::Escape($wslIp)) {
    Write-Host "Verification failed: portproxy listing does not contain $wslIp" -ForegroundColor Red
    exit 1
}

Remove-NetFirewallRule -DisplayName 'homeDX Backend 4000' -ErrorAction SilentlyContinue | Out-Null
New-NetFirewallRule -DisplayName 'homeDX Backend 4000' -Direction Inbound -Protocol TCP -LocalPort 4000 -Action Allow -Profile Domain,Private,Public | Out-Null

Write-Host "Firewall rule added (Domain,Private,Public) for TCP 4000" -ForegroundColor Green
Write-Host ""
Write-Host "Done. Phone .env: API_BASE_URL=http://<Windows Wi-Fi/Ethernet IPv4>:4000 (ipconfig on Windows — not the WSL IP)." -ForegroundColor Yellow
