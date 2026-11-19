# SOUP List (Software of Unknown Provenance)

**Date generated:** 2026-07-02  
**Updated:** 2026-10-07 (`proxy-addr` 2.0.8 override); 2026-11-17 (iOS CubeReader SDK); 2026-11-19 (Nest 11.2.11, `@nestjs/jwt` 11.0.2, resolved transitive runtime upgrades incl. express, multer, jsonwebtoken/jws/jwa)  
**Scope:** direct dependencies of `backend/` and `frontend/mobile/hdx_mobile/`.

> Per IEC 62304, SOUP items are third-party components not developed for
> this project under the same lifecycle process. This list is a starting
> inventory generated from `package.json`/`pubspec.yaml` — it records
> *what* is used, not a formal risk assessment of each item. A completed
> SOUP record additionally needs, per component: known anomalies/CVE
> tracking, and a statement of why it's fit for its intended use. That
> part still requires an ongoing process (CI runs `npm audit --audit-level=critical`
> on the backend; Flutter uses `flutter analyze` / `flutter test`). This is
> not a one-time document.

## Backend (`backend/package.json`)

| Package | Version | Role |
|---|---|---|
| `@nestjs/common`, `@nestjs/core`, `@nestjs/platform-express` | ^11.2.11 | Framework |
| `@nestjs/jwt`, `@nestjs/passport`, `passport`, `passport-jwt` | ^11.0.2 / ^11.0.5 / ^0.7.0 / ^4.0.1 | Auth |
| `@nestjs/throttler` | ^6.5.0 | Rate limiting |
| `@prisma/client`, `prisma` | ^6.9.0 / 6.9.0 | ORM / DB access (regulated data path) |
| `bcrypt` | ^6.0.0 | Password hashing |
| `pdfkit` | ^0.17.1 | Certificate PDF generation (regulated output) |
| `stripe` | ^20.0.0 | Payments |
| `@paypal/checkout-server-sdk`, `@paypal/paypal-server-sdk` | ^1.0.3 / ^2.0.0 | Payments |
| `firebase-admin` | ^13.4.0 | Push notifications |
| `helmet` | ^8.2.0 | HTTP security headers |
| Transitive `proxy-addr` | **2.0.8** via `package.json` `overrides` | Express client-IP trust (`req.ip`); CVE-2026-90711 (GHSA-jqcg-44mw-7w3h) |
| Transitive `express` | 5.2.1 (was 5.1.0), resolved via lockfile | HTTP server; pulled by `@nestjs/platform-express` 11.2.11 (2026-11-19) |
| Transitive `body-parser` | 2.4.0 (was 2.2.0) | Request body parsing; DoS fixes |
| Transitive `path-to-regexp` | 8.4.2 (was 8.2.0) | Route matching; DoS fix |
| Transitive `qs` | 6.17.1 | Query parsing; DoS fix |
| Transitive `multer` | 2.5.0 (was 2.0.2) | Multipart/media uploads (`FileInterceptor`); DoS fixes |
| Transitive `file-type` | 21.3.4 | Used by `@nestjs/common` file validation; DoS fix |
| Transitive `jsonwebtoken` | 9.0.3 (was 9.0.2) | JWT sign/verify (auth) |
| Transitive `jws` / `jwa` | 4.0.1 / 2.0.1 (were 3.2.2 / 1.4.2) | JWT signature primitives (auth). jws 3 to 4 only changes the `jwa` major and rejects empty HMAC secrets (GHSA-869p-cjfg-cm3x); `getJwtSecret()` already throws on an empty secret. Guard pins `algorithms: ['HS256']`; negative-path e2e in `backend/test/jwt-auth-negative.e2e-spec.ts` |
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
| `flutter_dotenv` | ^6.0.1 | Runtime config (`.env`) |
| `shared_preferences` | ^2.2.3 | Non-sensitive local prefs (locale) |
| `flutter_blue_plus` | ^1.32.7 | Bluetooth (generic; Cube pairing itself uses the native SDK bridge below) |
| `permission_handler` | ^11.3.1 | Runtime BT/camera permissions |
| `file_picker` | ^8.1.6 | Test photo/video/ID upload |
| `flutter_stripe` | ^11.1.0 | Payments |
| `com.google.android.material:material` (Android, Gradle) | 1.6.0 | Android UI theme (Theme.MaterialComponents), pulled in for Stripe PaymentSheet; not result logic |
| `androidx.appcompat:appcompat` (Android, Gradle, transitive via stripe_android) | 1.4.1 | Android UI base theme, pulled in for Stripe PaymentSheet; not result logic |
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

| Component | Platform | Version | Vendor | Provenance | Notes |
|---|---|---|---|---|---|
| Cube analysis SDK (`cubelib`, AAR) | Android | TBD | TBD (Cube manufacturer) | `android/app/libs/cubelib-release.aar` (committed) | Bridge: `CubeAnalysisMethodChannel.kt` |
| `CubeReader.xcframework` | iOS (min. iOS 17) | 1.3.0 | BIOSYNEX Technologies GmbH | Vendor zip `iOS-CubeReader-1.3.0.xcframework.zip` delivered 2026-11-12, SHA-256 `55f780b2d9dfd003d88afcd07451bd7334ec7825cbe2c8f5f0bc240e81fafec5`. **Not in git** (proprietary, "All Rights Reserved"); placed locally in `ios/CubeSDK/` and linked through the local `CubeReader` pod (`ios/CubeSDK/CubeReader.podspec`). CI builds without it. | Purpose: on-device test evaluation by the Cube, BLE communication, license handling, local measurement store (SwiftData). Bridge: `ios/Runner/Cube/` (`CubeReaderAdapter.swift`). Validation status: TBD. Known anomalies: TBD. Update process: TBD with BIOSYNEX. No CE status is claimed here. |

## Known gaps in this process (not just this list)

- No Dependabot/Renovate config exists to flag new CVEs automatically.
- No `npm audit` (or Flutter equivalent) step runs in CI.
- This document is a snapshot; it will drift the moment a dependency is
  bumped unless someone remembers to update it, or it's regenerated as
  part of a release process.
