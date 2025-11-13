# PowerShell script to forward Windows port 4000 to WSL2
# Run this from Windows PowerShell as Administrator
# Usage: Right-click PowerShell -> Run as Administrator, then run: .\setup-wsl-port-forward.ps1

$wslIP = (wsl hostname -I).Trim()
Write-Host "WSL2 IP: $wslIP"

# Remove existing port forwarding if any
netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=0.0.0.0 2>$null
netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=127.0.0.1 2>$null

# Add port forwarding for both 0.0.0.0 and 127.0.0.1
netsh interface portproxy add v4tov4 listenport=4000 listenaddress=0.0.0.0 connectport=4000 connectaddress=$wslIP
netsh interface portproxy add v4tov4 listenport=4000 listenaddress=127.0.0.1 connectport=4000 connectaddress=$wslIP

Write-Host ""
Write-Host "Port forwarding set up: Windows localhost:4000 -> WSL2 $wslIP:4000"
Write-Host ""
netsh interface portproxy show all

Write-Host ""
Write-Host "Note: If you restart WSL2, the IP may change. Run this script again if needed."
