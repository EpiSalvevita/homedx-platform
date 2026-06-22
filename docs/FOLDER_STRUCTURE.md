# homeDX Platform - Folder Structure

## Overview

- `backend/` – NestJS REST API (PostgreSQL + Prisma)
- `frontend/mobile/hdx_mobile/` – Flutter app (current client: Android, iOS, web)
- `Cube APP V0.1.21/` – Cube Android SDK package/documentation
- `Cube/` – Cube-related reference/license files
- `docs/` – Detailed setup docs
- `deploy.sh`, `stop.sh` – start/stop services
- `check-homedx-connectivity.ps1` – Windows: verify LAN IP, portproxy, and TCP 4000
- `setup-wsl-port-forward.cmd` / `setup-wsl-port-forward.ps1` – WSL2 port forwarding (run as Admin on Windows; prefer `.cmd` to avoid PowerShell execution-policy issues)

## Backend (`backend/`)

- **Entry:** `src/main.ts`, `src/app.module.ts`
- **REST API:** `src/controllers/mobile.controller.ts` → `/gg-homedx-json/gg-api/v1`
- **Webhooks:** `src/controllers/webhooks.controller.ts` → `/webhooks/stripe`, `/webhooks/paypal`
- **Data:** `prisma/schema.prisma`, migrations in `prisma/migrations/`
- **Tests:** `test/*.e2e-spec.ts` (Jest e2e with Postgres)

## Flutter app (`frontend/mobile/hdx_mobile/`)

- **Entry:** `lib/main.dart`
- **Routes:** `lib/config/app_router.dart`
- **HTTP client:** `lib/services/api_service.dart` (all backend calls)
- **Payments:** `lib/services/payment_service.dart` (Stripe / PayPal via REST)
- **Cube:** `lib/services/cube_service.dart` + Android `CubeBridge` Kotlin bridge
- **Config:** `.env` (`API_BASE_URL`, `STRIPE_PUBLISHABLE_KEY`)

## Reference / vendor (not the active app)

- `Cube APP V0.1.21/` – Vendor Cube sample and SDK bits
- `Cube/` – License and integration reference files
- `mobile/` – Deprecated React Native tree (use `frontend/mobile/hdx_mobile/`)
- `flutter/` – Local Flutter SDK checkout (framework, not a project)

## Quick pointers

- Backend dev server: `cd backend && npm run start:dev` (listens on `0.0.0.0:4000`)
- Flutter app: `cd frontend/mobile/hdx_mobile && flutter run`
- Cube Android reference: `Cube APP V0.1.21/`
