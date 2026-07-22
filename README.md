# homeDX Platform

This repository hosts the full homeDX stack:

- `backend/` – NestJS API (PostgreSQL + Prisma)
- `frontend/mobile/hdx_mobile/` – Flutter app (current client)
- `vendor/` – Cube SDK reference material (local; app AAR under `frontend/mobile/hdx_mobile/android/app/libs/`)

## Architecture

```
┌─────────────┐    Bluetooth    ┌─────────────┐
│ Cube Device │◄──────────────►│    Phone    │
└─────────────┘                 └──────┬──────┘
                                       │ REST API
                                       ▼
                                ┌─────────────┐
                                │   Backend   │
                                │  (NestJS)   │
                                └─────────────┘
```

**API:** `POST /gg-homedx-json/gg-api/v1/*` (JWT auth). No GraphQL.

**Data Flow:**
1. Phone connects to Cube device via Bluetooth (Cube SDK filters scan to Cube devices only). If Android asks for a pairing PIN/passkey, use the **last six digits of the Cube serial number**.
2. User starts measurement; Cube SDK runs evaluation on-device
3. Phone reads measurement results from Cube SDK
4. Phone sends processed result data to Backend API (`POST /submit-cube-data`)
5. Backend stores results and returns the normalized response
6. Phone displays test results to user

## Prerequisites

- WSL2 + Docker Desktop (backend DB)
- Node.js 20 LTS (backend)
- Flutter SDK (`frontend/mobile/hdx_mobile/`)
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
forwarding so it can reach the backend in WSL2. Run **as Administrator** from the
repo root.

**Recommended** (avoids PowerShell execution-policy blocks on unsigned scripts):

```cmd
.\scripts\wsl\setup-wsl-port-forward.cmd
```

**Alternative** (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\wsl\setup-wsl-port-forward.ps1
```

From WSL (triggers UAC on Windows):

```bash
./scripts/wsl/run-wsl-port-forward-elevated.sh
```

See [`docs/WSL2_PORT_FORWARDING.md`](docs/WSL2_PORT_FORWARDING.md) for manual setup and verification.

**Connectivity check (Windows PowerShell, repo root):**

```powershell
.\scripts\wsl\check-homedx-connectivity.ps1
```

Optional `-UpdateMobileEnv` updates `frontend/mobile/hdx_mobile/.env` to your current LAN IPv4 (then rebuild the app). Details in [`docs/ENV_SETUP.md`](docs/ENV_SETUP.md).

## Docs

- [`docs/README.md`](docs/README.md) – docs index
- [`docs/MOBILE_APP.md`](docs/MOBILE_APP.md)
- [`docs/APP_FUNCTIONALITIES.md`](docs/APP_FUNCTIONALITIES.md)
- [`docs/FOLDER_STRUCTURE.md`](docs/FOLDER_STRUCTURE.md)
- [`docs/ENV_SETUP.md`](docs/ENV_SETUP.md)
- [`docs/WSL2_PORT_FORWARDING.md`](docs/WSL2_PORT_FORWARDING.md)
- [`docs/APPOINTMENTS_VIDEO.md`](docs/APPOINTMENTS_VIDEO.md)
- [`docs/NAS_DEPLOY.md`](docs/NAS_DEPLOY.md)
