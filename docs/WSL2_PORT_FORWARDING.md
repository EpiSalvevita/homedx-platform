---
description: Detailed WSL2 port forwarding setup
---

# WSL2 Port Forwarding Setup

## Problem

When running the backend in WSL2 and the Flutter app on an Android emulator or phone,
you may see timeouts because the app cannot reach the WSL2 backend.

## Quick Setup (Recommended)

From the repo root, run in Windows PowerShell as Administrator:

```powershell
.\setup-wsl-port-forward.ps1
```

The script detects your WSL2 IP, forwards Windows port 4000 to WSL2 port 4000,
and creates a Windows Firewall rule for port 4000.

## Manual Setup

1) Get your WSL2 IP:
```bash
hostname -I | awk '{print $1}'
```

2) Add portproxy rules (PowerShell Admin):
```powershell
netsh interface portproxy add v4tov4 listenport=4000 listenaddress=0.0.0.0 connectport=4000 connectaddress=<wsl-ip>
netsh interface portproxy add v4tov4 listenport=4000 listenaddress=127.0.0.1 connectport=4000 connectaddress=<wsl-ip>
```

3) Open the firewall (Admin):
```powershell
New-NetFirewallRule -DisplayName "homeDX Backend 4000" -Direction Inbound -Protocol TCP -LocalPort 4000 -Action Allow
```

4) Verify:
```powershell
netsh interface portproxy show all
Invoke-RestMethod -Uri "http://<windows-lan-ip>:4000/gg-homedx-json/gg-api/v1/get-be-status-flags" -Method Post -ContentType "application/json" -Body "{}"
```

## Notes

- You must run PowerShell as Administrator.
- WSL2 IP can change after restart; rerun the script if that happens.
- Backend must listen on `0.0.0.0:4000`.
