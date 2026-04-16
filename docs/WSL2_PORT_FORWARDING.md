---
description: Detailed WSL2 port forwarding setup
---

# WSL2 Port Forwarding Setup

## Problem

When running the backend in WSL2 and the Flutter app on an Android emulator or phone,
you may see timeouts because the app cannot reach the WSL2 backend.

## Quick Setup (Recommended)

From the repo root, run **as Administrator**. Prefer the batch launcher so Windows
does not block the PowerShell script under execution policy:

```cmd
.\setup-wsl-port-forward.cmd
```

That runs `setup-wsl-port-forward.ps1` with `-ExecutionPolicy Bypass`. If you run
the `.ps1` directly and see a signing or execution-policy error, use:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-wsl-port-forward.ps1
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

## Flutter app: `API_BASE_URL` (physical phone)

Traffic path is: **phone → Windows (LAN IP) → port proxy → WSL (backend)**. The app must use **`http://<Windows IPv4>:4000`**, where that IPv4 is the **Wi‑Fi or Ethernet** interface your PC uses on the home network — **not** the WSL address (`hostname -I` in WSL).

- **Android emulator on Windows:** often `http://10.0.2.2:4000` (see `ENV_SETUP.md`).
- **Physical device:** set `API_BASE_URL` to `http://<IPv4>:4000` where `<IPv4>` comes from **`ipconfig`** on Windows (Wi‑Fi or Ethernet), not from WSL.

If login or API calls **time out**, suspect a **stale `API_BASE_URL`** (DHCP changed your PC’s address) before debugging Nest or Prisma.

## Check script (Windows)

From the repo root in **PowerShell** (Admin not required for most checks):

```powershell
.\check-homedx-connectivity.ps1
```

Shows LAN IPs, WSL IP, `netsh` portproxy, and `Test-NetConnection` to `127.0.0.1:4000`. **`TcpTestSucceeded : True`** means Windows can reach the forwarded port (backend should be running in WSL).

**Update `frontend/mobile/hdx_mobile/.env` automatically** to the current preferred LAN IPv4:

```powershell
.\check-homedx-connectivity.ps1 -UpdateMobileEnv
```

Then **rebuild** the Flutter app (not hot reload).

## Notes

- You must run the launcher **as Administrator** (elevated cmd or PowerShell).
- WSL2 IP can change after restart; rerun the script if that happens.
- Backend must listen on `0.0.0.0:4000`.
