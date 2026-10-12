# Changelog

homeDX did not previously track versioned changes (see
[`docs/regulatory/gap-assessment.md`](docs/regulatory/gap-assessment.md),
§9). This file starts that discipline going forward; it does not
retroactively document history before this entry.

Format: one entry per release, backend and mobile versioned
independently (`backend/package.json`, `frontend/mobile/hdx_mobile/pubspec.yaml`).

## Unreleased

**Mobile: localization (de / en):**
- UI strings for the auth, profile, navigation, Bluetooth and test flow,
  appointments and doctor, shop, cart, checkout, certificate, questionnaire
  chrome and payment screens now come from ARB files (`lib/l10n/app_de.arb`,
  `lib/l10n/app_en.arb`) via Flutter gen-l10n. Access is `context.l10n.<key>`.
- Not translated on purpose (regulated or clinical text, needs review before
  changing): Cube SDK messages and measurement error text
  (`features/cube/`), questionnaire question and answer content, legal pages,
  and the Cube license message.
- English translations are first drafts and need review by a native speaker,
  especially payment, medical and legal wording.

**Mobile: web app layout:**
- Page titles and content share one 800 px column in the web shell
  (`widgets/web/adaptive_screen.dart`).
- Payments shows its page title on web.
- Home quick-action grid is three columns on web (two full rows).
- Pill buttons no longer wrap their label; "Meine Termine" and the
  Notifications empty state use the 1600 px illustrations.

**Backend:**
- Fallback payment descriptions (`payment.service.ts`, PayPal order in
  `paypal.service.ts`) are German (`Zahlung über …`). Payments created before
  this change keep their English descriptions.

**Regulatory note (localization and web layout, Unreleased):**
- Regulatory-relevant: **yes, use-related only** (IEC 62366-1). Result and
  certificate labels and wording moved into ARB files. The German text was
  copied as-is, and the English text is new.
- Not changed: result logic, thresholds, rounding, status mapping
  (`normalizeCubeResult`, `UserTestResult` classification), Cube data handling,
  certificate content. Verified by reading the diff (`git diff 47228d58 912432b1`).
  `testTypeDisplayName` now takes localized strings; the mapping is unchanged.
- Failure modes (ISO 14971): a wrong English label or status word on a result
  or certificate, a German string dropped or changed during copy, or a missing
  translation falling back to German. Not verified by any automated test.
- Test evidence: `flutter analyze` clean and `flutter test` (119 passing) on
  the merged code. Backend change is two fallback description strings;
  `tsc --noEmit` only. No backend e2e run.
- Sign-off: **needed before English is offered to patients.** A human or the
  PRRC should review the English result and certificate wording, and check that
  the German strings match the pre-change text. Known open wording issue
  (`mdr-compliance.mdc`): the "Empfohlen" specialist claim.

## Mobile 1.1.2+4 — 2026-10-07

**Brand / UI:**
- Replaced AI and no-neck placeholder art with official style-guide logos
  and illustrations (`assets/images/brand/`, `assets/images/illustrations/`).
- Incubation progress heading is static **Inkubationszeit**; countdown lives
  only on the clock.

**Regulatory-relevant (result display, not Cube class parsing):**
- Ergebnisse list and detail now share `UserTestResult` classification.
  Pending / in-progress tests show **Ausstehend**, not **Unbestimmt**.
  Completed tests without a readable class remain Unbestimmt.
- Test evidence: `test_result_badge_test.dart`, `test_result_screen_test.dart`.

**Docs:** `docs/regulatory/gap-assessment.md`, `docs/APP_FUNCTIONALITIES.md`,
`docs/regulatory/soup-list.md`.

**CI:** Drop unused `assets/images/marketing/` from `pubspec.yaml`. Pin
transitive `proxy-addr` to 2.0.8 (CVE-2026-90711) so `npm audit --audit-level=critical` passes.

**Regulatory note:** Use-related (IEC 62366-1): do not present “no result
yet” as a clinical inconclusive. Does not change backend
`normalizeCubeResult` or on-device Cube evaluation.

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
