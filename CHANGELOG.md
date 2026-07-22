# Changelog

homeDX did not previously track versioned changes (see
[`docs/regulatory/gap-assessment.md`](docs/regulatory/gap-assessment.md),
§9). This file starts that discipline going forward; it does not
retroactively document history before this entry.

Format: one entry per release, backend and mobile versioned
independently (`backend/package.json`, `frontend/mobile/hdx_mobile/pubspec.yaml`).

## Backend 0.2.1 / Mobile 1.1.1+3 — 2026-07-22

**Platform hygiene / structure (non-result-path):**
- Removed legacy root `mobile/` tree, RN leftovers in `deploy.sh`/`stop.sh`, dead GraphQL-era services (`LicenseService`, `CertificateService`, `TestKitService`), and unused PayPal checkout SDK.
- Nest feature modules under `backend/src/modules/`; merged `util/` into `utils/`.
- Cube vendor refs moved to `vendor/` (gitignored); Flutter `lib/core/` + `lib/features/cube/`; Android id `com.homedx.app`.
- `RapidTest.source` default is now `mobile` (existing rows unchanged); `License` table retained with schema notes (no active API).
- Removed unused `get-live-token`; kept `init-authentication` / `unset-authentication` for Flutter web/session.

**Regulatory-relevant (result path / classification):**
- Flutter `CubeService._determineResultString` no longer thresholds on
  numeric `value` or defaults to `NEGATIVE`; uses Cube `class` only and
  fails closed to `INCONCLUSIVE` (aligned with backend).
- Backend `normalizeCubeResult` prefers `resultData[].class`; if result
  rows exist without a usable class, ignores client-invented POS/NEG →
  `INCONCLUSIVE`. Added e2e coverage.
- Release builds force `CUBE_USE_TIMER=true` (ignore `.env` skip).
- Added `docs/regulatory/classification-draft.md` (draft IVDR Class C;
  MDR Rule 11 analogy Class IIa for RA test → specialist video pathway).
- Refreshed `docs/regulatory/gap-assessment.md`.

**Regulatory note:** Touches result interpretation authority (ISO 14971 /
accessory assumption). Test evidence: Flutter `cube_service_test.dart`,
backend `submit-cube-data.e2e-spec.ts`. PRRC should confirm classification
draft before any CE / marketing claim. Human sign-off recommended before
production reliance on the new fail-closed behaviour for empty classes.

## Backend 0.2.0 / Mobile 1.1.0+2 — 2026-07-02

Closes several engineering gaps identified in the regulatory gap-scan.
See that document for full context; each item below also carries an
in-code "Regulatory note" per `.cursor/rules/mdr-compliance.mdc` §10.

**Regulatory-relevant:**
- Certificate auto-issuance now checks the underlying `RapidTest.result`
  and only issues for `POSITIVE`/`NEGATIVE`; `INVALID`/`INCONCLUSIVE`/unset
  results are no longer auto-certified (`mobile-certificate.service.ts`).
- `AuditLog` is now written on login, Cube data submission, and
  certificate issuance (previously modeled but never populated).
- Consent screen (`test_submission_screen.dart`) now links to the
  Privacy Policy and Terms pages instead of referencing them as
  non-interactive text. Backed by a new public `get-legal-page` endpoint
  exposing the existing (already-populated) `LegalPage` content.
- Certificate list/detail screens are now reachable via app navigation
  (`/certificates`, `/certificates/:id`) — previously built but unrouted.
- Mobile Cube logging (`CUBE_VERBOSE`) now defaults to off in release
  builds when not explicitly configured, instead of defaulting on.

**Housekeeping:**
- Backend `package.json` now has `name`/`version` fields (previously
  absent).
- Added `docs/regulatory/soup-list.md` (SOUP / dependency inventory).
- Added test coverage for `INVALID`/`INCONCLUSIVE` result paths (backend
  normalization + certificate gate; mobile result badges).

**Not addressed in this release (see gap-assessment.md for why):**
- MDR/IVDR/DiGA classification — requires a qualified regulatory review,
  not a code change.
- GDPR erasure/anonymization endpoint — requires a retention-policy
  decision before implementation.
- Result-badge color scheme (positive/error hue overlap) — requires
  design review.
