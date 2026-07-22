#!/bin/bash
# Prints the Windows Admin steps for WSL2 port 4000 forwarding.
# Phones reach Windows:4000 on your LAN IP; that requires listenaddress=0.0.0.0
# (127.0.0.1 alone is not enough). Prefer: scripts/wsl/setup-wsl-port-forward.cmd as Administrator.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WSL_IP=$(hostname -I | awk '{print $1}')
echo "WSL2 IP (portproxy connectaddress): $WSL_IP"
echo ""
echo "Run on Windows as Administrator (from repo root):"
echo "  .\\scripts\\wsl\\setup-wsl-port-forward.cmd"
echo ""
echo "Or in elevated PowerShell, same rules as setup-wsl-port-forward.ps1:"
echo "  netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=0.0.0.0 2>nul"
echo "  netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=127.0.0.1 2>nul"
echo "  netsh interface portproxy add v4tov4 listenport=4000 listenaddress=0.0.0.0 connectport=4000 connectaddress=$WSL_IP"
echo "  netsh interface portproxy add v4tov4 listenport=4000 listenaddress=127.0.0.1 connectport=4000 connectaddress=$WSL_IP"
echo ""
echo "Then open Windows Firewall for TCP 4000 (see docs/WSL2_PORT_FORWARDING.md)."
echo "Flutter physical device: API_BASE_URL=http://<Windows Wi-Fi IPv4>:4000 in frontend/mobile/hdx_mobile/.env"
echo "Repo root: $ROOT"
