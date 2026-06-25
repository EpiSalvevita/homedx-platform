#Requires -RunAsAdministrator
<#
 homeDX Platform - WSL2 port forwarding for backend (TCP 4000).
 Must run elevated: netsh portproxy + Windows Firewall.
 From WSL repo root: ./run-wsl-port-forward-elevated.sh (copies into %TEMP% and triggers UAC)
 (elevated shells often fail to execute scripts from \\wsl$\ UNC roots).
#>
$ErrorActionPreference = 'Stop'

function Get-WslBackendIp {
    # Prefer primary WSL NIC (eth0 mirrored, or eth1 LAN); skip docker bridges.
    $raw = (& wsl.exe -e /bin/sh -c @'
for iface in eth0 eth1; do
  ip -4 -o addr show "$iface" 2>/dev/null | awk '{print $4}' | cut -d/ -f1
done
ip -4 -o addr show 2>/dev/null | awk '{print $4}' | cut -d/ -f1
'@ 2>$null)
    $ips = @($raw -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}$' })
    foreach ($ip in $ips) {
        if ($ip -match '^127\.' -or $ip -match '^10\.255\.255\.') { continue }
        if ($ip -match '^172\.(1[6-9]|2[0-9]|3[0-1])\.' -and $ip -notmatch '^172\.(25|26)\.') { continue }
        return $ip
    }
    if ($ips.Count -gt 0) { return $ips[0] }
    throw "Could not read a usable WSL IP (eth0/eth1 / ip addr)."
}

function Get-WslBackendPort {
    $port = (& wsl.exe -e /bin/sh -c @'
node -e "require('net').createServer().listen(4000,'0.0.0.0',function(){this.close();process.exit(0)}).on('error',()=>process.exit(1))" 2>/dev/null && echo 4000 || echo 4010
'@ 2>$null).Trim()
    if ($port -notmatch '^(4000|4010)$') { return '4010' }
    return $port
}

$wslIp = Get-WslBackendIp
$connectPort = Get-WslBackendPort

Write-Host "WSL2 IP (connect target): $wslIp" -ForegroundColor Cyan
Write-Host "WSL backend port: $connectPort (Windows still listens on 4000)" -ForegroundColor Cyan

# Remove stale rules (ignore exit code if missing)
Start-Process -FilePath netsh.exe -ArgumentList @('interface','portproxy','delete','v4tov4','listenport=4000','listenaddress=0.0.0.0') -Wait -NoNewWindow -PassThru | Out-Null
Start-Process -FilePath netsh.exe -ArgumentList @('interface','portproxy','delete','v4tov4','listenport=4000','listenaddress=127.0.0.1') -Wait -NoNewWindow -PassThru | Out-Null

$p1 = Start-Process -FilePath netsh.exe -ArgumentList @('interface','portproxy','add','v4tov4','listenport=4000','listenaddress=0.0.0.0','connectport=' + $connectPort,"connectaddress=$wslIp") -Wait -NoNewWindow -PassThru
if ($p1.ExitCode -ne 0) {
    Write-Host "netsh add (0.0.0.0:4000) failed with exit $($p1.ExitCode)" -ForegroundColor Red
    exit $p1.ExitCode
}
$p2 = Start-Process -FilePath netsh.exe -ArgumentList @('interface','portproxy','add','v4tov4','listenport=4000','listenaddress=127.0.0.1','connectport=' + $connectPort,"connectaddress=$wslIp") -Wait -NoNewWindow -PassThru
if ($p2.ExitCode -ne 0) {
    Write-Host "netsh add (127.0.0.1:4000) failed with exit $($p2.ExitCode)" -ForegroundColor Red
    exit $p2.ExitCode
}

Write-Host "Port proxy rules added for 4000 -> ${wslIp}:${connectPort}" -ForegroundColor Green

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
Write-Host "Done. Flutter .env: API_BASE_URL=http://localhost:4000 (browser) or http://<Windows Wi-Fi IPv4>:4000 (phone)." -ForegroundColor Yellow
if ($connectPort -eq '4010') {
    Write-Host "Note: WSL could not bind 4000; backend should run with PORT=4010 in backend/.env" -ForegroundColor Yellow
}
