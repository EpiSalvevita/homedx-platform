# SOUP List (Software of Unknown Provenance)

**Date generated:** 2026-07-02
**Scope:** direct dependencies of `backend/` and `frontend/mobile/hdx_mobile/`.

> Per IEC 62304, SOUP items are third-party components not developed for
> this project under the same lifecycle process. This list is a starting
> inventory generated from `package.json`/`pubspec.yaml` — it records
> *what* is used, not a formal risk assessment of each item. A completed
> SOUP record additionally needs, per component: known anomalies/CVE
> tracking, and a statement of why it's fit for its intended use. That
> part still requires an ongoing process (e.g. `npm audit` / `flutter pub
> outdated` in CI — currently absent, see `gap-assessment.md` §3), not a
> one-time document.

## Backend (`backend/package.json`)

| Package | Version | Role |
|---|---|---|
| `@nestjs/common`, `@nestjs/core`, `@nestjs/platform-express` | ^11.1.3 / ^11.1.6 | Framework |
| `@nestjs/jwt`, `@nestjs/passport`, `passport`, `passport-jwt` | ^11.0.0 / ^11.0.5 / ^0.7.0 / ^4.0.1 | Auth |
| `@nestjs/throttler` | ^6.5.0 | Rate limiting |
| `@prisma/client`, `prisma` | ^6.9.0 / 6.9.0 | ORM / DB access (regulated data path) |
| `bcrypt` | ^6.0.0 | Password hashing |
| `pdfkit` | ^0.17.1 | Certificate PDF generation (regulated output) |
| `stripe` | ^20.0.0 | Payments |
| `@paypal/checkout-server-sdk`, `@paypal/paypal-server-sdk` | ^1.0.3 / ^2.0.0 | Payments |
| `firebase-admin` | ^13.4.0 | Push notifications |
| `helmet` | ^8.2.0 | HTTP security headers |
| `class-validator`, `class-transformer` | ^0.14.2 / ^0.5.1 | Input validation (incl. Cube/RapidTest DTOs) |
| `cookie-parser` | ^1.4.7 | Auth cookie handling |
| `reflect-metadata`, `rxjs`, `tslib` | — | Framework runtime deps |
| Dev/test: `jest`, `ts-jest`, `supertest`, `eslint`, `typescript` | — | Build/test tooling only, not shipped |

## Mobile (`frontend/mobile/hdx_mobile/pubspec.yaml`)

| Package | Version | Role |
|---|---|---|
| `provider` | ^6.1.2 | State management |
| `go_router` | ^14.2.7 | Navigation |
| `http` | ^1.2.2 | REST client to backend |
| `flutter_secure_storage` | ^9.2.4 | Encrypted JWT/PII storage |
| `flutter_dotenv` | ^5.1.0 | Runtime config (`.env`) |
| `shared_preferences` | ^2.2.3 | Non-sensitive local prefs (locale) |
| `flutter_blue_plus` | ^1.32.7 | Bluetooth (generic; Cube pairing itself uses the native SDK bridge below) |
| `permission_handler` | ^11.3.1 | Runtime BT/camera permissions |
| `file_picker` | ^8.1.6 | Test photo/video/ID upload |
| `flutter_stripe` | ^11.1.0 | Payments |
| `webview_flutter` | ^4.9.0 | PayPal checkout |
| `firebase_core`, `firebase_messaging` | ^3.8.1 / ^15.1.6 | Push notifications |
| `google_fonts`, `cupertino_icons`, `intl`, `url_launcher` | — | UI/formatting, not regulated-surface |
| Dev: `flutter_lints`, `flutter_launcher_icons` | — | Build tooling only |

**Native/vendor SDK (not a pub package):** the Cube analysis SDK, bridged
via `android/app/src/main/kotlin/.../CubeAnalysisMethodChannel.kt` and the
Dart `MethodChannel('com.homedx.cube/analysis')` /
`EventChannel('com.homedx.cube/events')`. This is the single most
regulatory-relevant SOUP item (it performs the actual IVD measurement)
and is **not tracked by any package manager here** — its version,
provenance, and update process should be documented by whoever owns the
Cube device integration agreement, not inferred from this repo.

## Known gaps in this process (not just this list)

- No Dependabot/Renovate config exists to flag new CVEs automatically.
- No `npm audit` (or Flutter equivalent) step runs in CI.
- This document is a snapshot; it will drift the moment a dependency is
  bumped unless someone remembers to update it, or it's regenerated as
  part of a release process.
