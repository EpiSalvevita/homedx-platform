# homeDX Platform - Folder Structure

## Overview

- `backend/` – NestJS REST API (PostgreSQL + Prisma)
- `frontend/mobile/hdx_mobile/` – Flutter app (current client: Android, iOS, web)
- `vendor/` – Cube SDK reference material (local/gitignored where binary; see below)
- `docs/` – Detailed setup docs
- `work/` – Non-code project space (market, meetings, roadmap, partnerships, brand, finance, notes)
- `deploy/nas/` – NAS/LAN Docker deploy (see `docs/NAS_DEPLOY.md`)
- `scripts/` – Git hooks; WSL helpers under `scripts/wsl/`
- `.claude/`, `.cursor/` – Agent configuration and rules (`.cursor/rules/`, `.claude/agents/`)
- `docs/exports/` – Exported review documents (not living docs)
- `work/imports/` – Questionnaire source material (handover packages, DOCX/PDF sources)
- `work/brand/style-guide/` – Brand source assets (fonts, logos, illustrations, colour palette)
- `deploy.sh`, `stop.sh` – local start/stop (repo root)
- `scripts/wsl/check-homedx-connectivity.ps1` – Windows: verify LAN IP, portproxy, and TCP 4000
- `scripts/wsl/setup-wsl-port-forward.cmd` / `.ps1` – WSL2 port forwarding (run as Admin on Windows; prefer `.cmd`)

## Backend (`backend/`)

- **Entry:** `src/main.ts`, `src/app.module.ts` (imports feature modules under `src/modules/`)
- **REST API:** `src/controllers/mobile-*.controller.ts` → `/gg-homedx-json/gg-api/v1`
- **Webhooks:** `src/controllers/webhooks.controller.ts` → `/webhooks/stripe`, `/webhooks/paypal`
- **Feature modules:** `auth`, `tests`, `payments`, `appointments`, `certificates`, `notifications`, `questionnaires`, `legal`, plus global `prisma` / `common`
- **Data:** `prisma/schema.prisma`, migrations in `prisma/migrations/`
- **Tests:** `test/*.e2e-spec.ts` (Jest e2e with Postgres)

## Flutter app (`frontend/mobile/hdx_mobile/`)

- **Entry:** `lib/main.dart`
- **Routes:** `lib/config/app_router.dart`
- **Core:** `lib/core/` (`api_service.dart`, `constants.dart`, HTTP client factory)
- **Cube:** `lib/features/cube/cube_service.dart` + Android `CubeBridge` (`com.homedx.app`)
- **Other services:** `lib/services/` (auth, payments, appointments, …)
- **Config:** `.env` (`API_BASE_URL`, `STRIPE_PUBLISHABLE_KEY`)
- **Android applicationId:** `com.homedx.app`
- **Troubleshooting notes:** the one-off `*.md` notes in the app folder are out of date. Use `docs/MOBILE_APP.md`, `docs/WSL2_MOBILE_SETUP.md` and `docs/ENV_SETUP.md` instead.

## Reference / vendor (not the active app)

- `vendor/cube-android/` – Vendor Cube Android sample and SDK bits (**gitignored** — keep a local copy for reference; AAR is vendored in `frontend/mobile/hdx_mobile/android/app/libs/`)
- `vendor/cube-windows/` – Windows DLL / license reference (local; not required for Android builds)
- `flutter/` – Local Flutter SDK checkout if present (framework, not a project; gitignored). Prefer installing the SDK outside this repo.

## Quick pointers

- Backend dev server: `cd backend && npm run start:dev` (listens on `0.0.0.0:4000`)
- Flutter app: `cd frontend/mobile/hdx_mobile && flutter run`
- Cube Android reference: `vendor/cube-android/` (local)
