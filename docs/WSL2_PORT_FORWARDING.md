---
description: Detailed WSL2 port forwarding setup
---

# WSL2 Port Forwarding Setup

## Problem

When running the backend in WSL2 and the Flutter app on an Android emulator or phone,
you may see timeouts because the app cannot reach the WSL2 backend.

> **Diagnose first:** On WSL2, a "network error" / "Failed to fetch" is almost always
> an **environment** issue (port ownership, `netsh` portproxy, IPv4 vs IPv6) — **not**
> app code. Before debugging Nest or Prisma, check who owns port 4000 and what the
> portproxy table says (see [Web app in the browser](#web-app-in-the-browser-same-pc)
> and [Troubleshooting](#troubleshooting)).

## Web app in the browser (same PC)

Running the Flutter **web** build in a browser on the same machine as WSL2 is the simplest
path and behaves differently from the phone/emulator case below.

- **You usually do NOT need any portproxy.** If WSL can bind `0.0.0.0:4000`, the Windows
  browser reaches the backend directly. Only add `netsh` rules for a **physical phone**
  on your LAN (see below).
- **Use `http://127.0.0.1:4000`, not `http://localhost:4000`.** On Windows, `localhost`
  resolves to IPv6 `::1`, but the backend binds IPv4 only (`backend/src/main.ts` →
  `app.listen(port, '0.0.0.0')`). So `localhost:4000` **times out** while `127.0.0.1:4000`
  works. The app already accounts for this: `frontend/mobile/hdx_mobile/lib/utils/constants.dart`
  rewrites `localhost` → `127.0.0.1` on web, and `.env` ships `API_BASE_URL=http://127.0.0.1:4000`.
- **Serve with SPA fallback** so deep links / refreshes on routes like `/home`, `/doctors`,
  `/results` don't return 404:
  ```bash
  cd frontend/mobile/hdx_mobile && ./serve-web.sh 8080
  ```
  Plain `python3 -m http.server` only serves real files on disk, so any non-root path 404s.
  Then open `http://127.0.0.1:8080`.

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

From **WSL** (repo root), you can run the bundled check (portproxy target vs current WSL IP, Flutter `.env` hint, backend smoke):

```bash
./deploy.sh connectivity
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

## Troubleshooting

### `TcpTestSucceeded: True` but login still times out (or HTTP tools fail)

`Test-NetConnection` only checks **TCP**. Some WSL2 + `netsh portproxy` setups accept the connection but **reset during the HTTP response**, so phones never get JSON (Flutter shows timeouts; `curl.exe` from Windows may show *connection reset*).

1. Run the full probe (TCP **and** HTTP) from **Windows PowerShell** at the repo root:
   ```powershell
   .\check-homedx-connectivity.ps1
   ```
   You need **HTTP OK** for both `http://127.0.0.1:4000/...` and `http://<your-LAN-IP>:4000/...`. If TCP is True and HTTP fails, portproxy is not enough on your machine.

2. **WSL mirrored networking (Windows 11, recommended try):**  
   Create or edit `%UserProfile%\.wslconfig`:
   ```ini
   [wsl2]
   networkingMode=mirrored
   ```
   Then run **`wsl --shutdown`**, start WSL again, start the backend, and run **`setup-wsl-port-forward.cmd`** again as Administrator.  
   [Microsoft: WSL networking](https://learn.microsoft.com/en-us/windows/wsl/networking)

3. **Run the backend on Windows** (bypasses WSL portproxy): start Nest in PowerShell on Windows with the same `backend/` project and a `DATABASE_URL` that reaches Postgres from Windows (e.g. Docker Desktop mapping `localhost:5432`). Bind remains `0.0.0.0:4000` in `main.ts`.

4. **Physical device + USB:** if you use **Windows** `adb`, you can try `adb reverse tcp:4000 tcp:4000` and set `API_BASE_URL=http://127.0.0.1:4000`, **but** that still hits Windows `127.0.0.1:4000` first — it will **not** fix the case where HTTP through portproxy is broken. Prefer mirrored networking or Windows-hosted Nest.

5. Stale **`API_BASE_URL`** after DHCP: run `.\check-homedx-connectivity.ps1 -UpdateMobileEnv` and **rebuild** the app (release APK must be rebuilt; hot reload does not refresh `.env`).

### Stale portproxy blocks WSL from binding 4000

**Symptoms:** the backend logs `EADDRINUSE: address already in use 0.0.0.0:4000` even though nothing is running in WSL, and the browser shows "Failed to fetch".

**Cause:** a leftover `netsh` rule (often `127.0.0.1 4000 → <old WSL IP> 4010`, left behind after a WSL restart changed the IP) holds the port on the **Windows** side and forwards to a dead target. Because Windows owns `127.0.0.1:4000`, WSL can no longer bind it, and `localhost:4000` from the browser is routed to nothing.

**Diagnose / fix:**

1. Show the current rules (from WSL or Windows):
   ```bash
   powershell.exe -NoProfile -Command "netsh interface portproxy show all"
   ```
   Look for any `4000` row whose connect target is not your **current** WSL IP, or that points at a different port (e.g. `4010`).

2. Test whether WSL can bind port 4000:
   ```bash
   node -e "require('net').createServer().listen(4000,'0.0.0.0',function(){this.close();console.log('ok')}).on('error',e=>console.log('fail',e.message))"
   ```
   `fail ... EADDRINUSE` with no WSL process listening points to a stale Windows rule.

3. Delete the stale rules (PowerShell **Admin**), then let WSL bind 4000 directly:
   ```powershell
   netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=0.0.0.0
   netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=127.0.0.1
   ```
   Or, from WSL, re-create correct rules for the **current** IP:
   ```bash
   ./run-wsl-port-forward-elevated.sh
   ```

4. After deleting, WSL can bind `0.0.0.0:4000` again and `http://127.0.0.1:4000` works from the browser. For **web-only dev on the same PC you do not need to re-add any portproxy** — only re-run the setup script when a physical phone needs the LAN path.
