# homeDX Platform

This repository hosts the full homeDX stack:

- `backend/` – NestJS API (PostgreSQL + Prisma)
- `frontend/mobile/hdx_mobile/` – Flutter app (current client)
- `Cube APP V0.1.21/` – Cube Android integration package/documentation
- `Cube/` – Cube reference files (including license data)

## Architecture

```
┌─────────────┐    Bluetooth    ┌─────────────┐
│ Cube Device │◄──────────────►│    Phone    │
└─────────────┘                 └──────┬──────┘
                                       │ HTTP API
                                       ▼
                                ┌─────────────┐
                                │   Backend   │
                                │  (NestJS)   │
                                └─────────────┘
```

**Data Flow:**
1. Phone connects to Cube device via Bluetooth (Cube SDK filters scan to Cube devices only)
2. User starts measurement; Cube SDK runs evaluation on-device
3. Phone reads measurement results from Cube SDK
4. Phone sends processed result data to Backend API (`POST /submit-cube-data`)
5. Backend stores results and returns the normalized response
6. Phone displays test results to user

## Prerequisites

- WSL2 + Docker Desktop (backend DB)
- Node.js 20 LTS (backend)
- Flutter SDK (mobile/hdx_mobile)
- Windows PowerShell (Admin) for WSL2 port forwarding

## Quick Start

Run the helper script from the repo root to bring everything online:

```bash
./deploy.sh all
```

Use `./deploy.sh backend` or `./deploy.sh mobile` to start individual parts.

Stop services with:

```bash
./stop.sh
```

## WSL2 Port Forwarding

If the app runs on a physical phone or Android emulator on Windows, set up port
forwarding so it can reach the backend in WSL2. Run as Administrator:

```powershell
.\setup-wsl-port-forward.ps1
```

See `docs/WSL2_PORT_FORWARDING.md` for manual setup.

## Docs

- `docs/README.md`
- `docs/MOBILE_APP.md`
- `docs/APP_FUNCTIONALITIES.md`
- `docs/FOLDER_STRUCTURE.md`
- `docs/ENV_SETUP.md`
- `frontend/README.md`




