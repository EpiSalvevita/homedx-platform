# homeDX Regulatory Engineering Gap-Scan

**Date:** 2026-07-02 (updated same day after a follow-up closure pass)
**Scope:** `backend/` (NestJS/Prisma) and `frontend/mobile/hdx_mobile/` (Flutter)
**Method:** static, read-only code/repo scan against the framework in
[`.cursor/rules/mdr-compliance.mdc`](../../.cursor/rules/mdr-compliance.mdc).

> **Update (same day):** several of the *engineering* gaps below (not the
> ones requiring a qualified regulatory/PRRC/legal decision) were closed in
> a follow-up change. See [`CHANGELOG.md`](../../CHANGELOG.md) (Backend
> 0.2.0 / Mobile 1.1.0+2) for the change list, and the **"Closed in this
> pass"** callouts inline below. Sections/items without that callout are
> still open exactly as originally assessed.

> **What this document is:** a code-derived list of what regulatory-relevant
> artifacts and practices exist vs. are missing in this repository, to feed
> into a real review.
>
> **What this document is not:** a legal or regulatory determination, a
> completed technical file, a risk management file, or a substitute for a
> qualified Person Responsible for Regulatory Compliance (PRRC), the Cube
> device manufacturer's Quality Management System, or Notified Body input.
> An AI coding agent cannot see documentation, contracts, or sign-offs that
> exist outside this codebase, and cannot make the MDR/IVDR/DiGA
> classification call. Every "gap" below is an *engineering* observation,
> not a finding of non-compliance — some may already be covered by
> documentation or process that lives outside this repo.

---

## 1. Scope and classification — unresolved

- No file in the repo states or confirms whether homeDX is regulated under
  **MDR**, **IVDR**, or **DiGA/DiGAV**, or confirms the "accessory to Cube"
  classification assumption used by `mdr-compliance.mdc`.
- **Gap:** classification decision is not documented anywhere in-repo (not a
  code fix — needs a qualified regulatory affairs review, per the rule's own
  section 1).

## 2. Roles

- No PRRC is named anywhere in the repo (expected — this is an
  organizational fact, not a code artifact).
- **Gap:** no `docs/regulatory` entry recording who the PRRC/manufacturer-of-record
  for the software is, so there's nowhere for engineers to check before
  escalating a regulated-surface change.

## 3. Software lifecycle — IEC 62304

**Test coverage on the regulated surface:**

| Area | Backend | Mobile |
|---|---|---|
| Cube data ingestion (`submit-cube-data`) | Covered — `test/submit-cube-data.e2e-spec.ts` | Covered — `test/services/cube_service_test.dart` |
| Result normalization (`POS`/`NEG` aliasing) | Covered | Covered |
| `INVALID` / `INCONCLUSIVE` handling | ✅ **Closed** — explicit `INVALID` cases added to `submit-cube-data.e2e-spec.ts` | ✅ **Closed** — `test_result_badge_test.dart` now asserts positive/invalid/inconclusive kind, color, icon, label |
| Certificate generation/issuance | ✅ **Closed** — `test/mobile-certificate.service.e2e-spec.ts` (8 cases: gate, idempotency, audit-failure isolation) | **Not tested** (no certificate widget tests beyond the new list-screen smoke test) |
| Certificate display/download | n/a | Partial — `certificates_list_screen_test.dart` added (list rendering, empty state); detail screen and PDF download still untested. Screens are now ✅ **wired into `app_router.dart`** (`/certificates`, `/certificates/:id`) |
| `RapidTest` finalize/status lifecycle | **Not tested** | Consent-gate on submission is tested; downstream status handling is not |
| Unit tests (backend) | Still **zero `*.spec.ts`** under `backend/src/`; new coverage was added as `.e2e-spec.ts` files instead (matches this repo's actual `test:e2e`-only CI config, see §9) | 18+ test files, good `CubeService`/screen coverage |
| Coverage gate in CI | **Not found** — no coverage threshold | `flutter test` runs, no coverage gate |

- **SOUP list:** ✅ **Closed (first pass)** — [`docs/regulatory/soup-list.md`](./soup-list.md)
  now inventories backend/mobile dependencies and the native Cube SDK. Still
  open: no Dependabot/Renovate config, no `npm audit` step in CI, so this
  will drift without a recurring process (see §9).
- **Versioning:** ✅ **Closed** — `backend/package.json` now has
  `name`/`version` (`0.2.0`). `pubspec.yaml` (`1.1.0+2`) and
  `lib/utils/constants.dart` (`appVersion = '1.1.0'`) are now kept in sync
  by convention with a comment pointing at the CHANGELOG; still manual, not
  enforced by tooling.
- ✅ **Closed** — [`CHANGELOG.md`](../../CHANGELOG.md) now exists at the repo
  root, covering both backend and mobile.
- **No SRS, architecture/design doc, or CAPA/problem-resolution log** found
  — still open; these need a qualified author, not a code change.

**Practical implication:** the regulated data path (Cube ingest → normalize
→ store → certify) has reasonable *entry-point* test coverage but weak
coverage on the *edge* results (`INVALID`/`INCONCLUSIVE`) and on
certificate issuance specifically — the artifact a user/authority is most
likely to actually rely on.

## 4. Risk management — ISO 14971

- **No risk management file / hazard log** exists in the repo.
- **Result interpretation logic** (`backend/src/services/cube.service.ts`,
  `normalizeCubeResult`, lines 50-73) does light string normalization only
  (aliasing `POS`→`POSITIVE`, defaulting unmatched values to
  `INCONCLUSIVE`) — it does not compute thresholds from raw values. This is
  lower risk than on-device interpretation, but the **default-to-INCONCLUSIVE
  fallback has no test** covering what happens when it's hit.
- ✅ **Closed** — `mobile-certificate.service.ts` (`issueForRapidTest`) now
  requires `result` to be `POSITIVE` or `NEGATIVE` before auto-issuing a
  certificate; `INVALID`/`INCONCLUSIVE`/unset results are rejected and
  logged, with test coverage. **This was a product decision, not a default
  engineering fix** — confirmed with the product owner before implementing
  (see CHANGELOG). A qualified reviewer should still confirm this is the
  clinically-correct gate, not just the technically-safer one.
- ✅ **Closed (mechanically)** — `AuditLogService.create` is now called from
  `AuthService.login`, `CubeService.submitCubeData`, and
  `MobileCertificateService.issueForRapidTest`, each wrapped so a logging
  failure never blocks the primary action. **Still open:** no one has
  decided what audit log *retention*, *access control*, or *review process*
  should be — writing rows is necessary but not sufficient for this to
  function as a real traceability control.
- **Mobile usability/result-confusion risk** (see §5) is itself a risk-management
  input that currently has no corresponding hazard entry anywhere.

## 5. Usability engineering — IEC 62366-1

From the mobile scan (`lib/config/app_theme.dart`, `lib/widgets/test_result_badge.dart`):

- **Positive result and error/failure states share the same coral color
  family** (`errorColor = accentCoral`; positive badge also uses
  `accentCoral` at 55% alpha). Distinguishable by icon and German label
  today, but a color-only or low-vision read could conflate "positive
  result" with "measurement failed."
- **Not fixed — deferred to design review.** Positive/error color overlap
  remains as-is; a deliberate decision, not an oversight this time. It is
  now pinned down by an explicit "KNOWN GAP" test in
  `test_result_badge_test.dart` so it can't silently regress further or be
  "fixed" by accident without someone noticing and updating the test.
- **Invalid results use a muted gray badge**, visually similar to the
  outlined "pending" state — another plausible confusion pair. Still open.
- **Post-measurement, pre-consent screen** (`test_submission_screen.dart`)
  shows the raw Cube result as **plain text** ("Cube-Ergebnis: …") with no
  badge/color/icon styling — the one moment a user is asked to confirm and
  submit, the result isn't shown with the same visual rigor as the later
  result screens. Still open (not part of this pass).
- ✅ **Closed** — `test_result_badge_test.dart` now asserts kind/color/icon/label
  for positive, invalid, and inconclusive, not just negative-vs-pending.
- Error/retry flow during a failed Cube measurement (`test_progress_screen.dart`)
  is clear and well-tested (explicit "Messung fehlgeschlagen" + retry
  button) — **this part is in good shape**.

## 6. Data protection and cybersecurity

- **Health-adjacent data is stored as plain, unencrypted columns**
  (`RapidTest.cubeResultData`/`cubeRawData` as `Json?`, `notes` as raw
  string, identity card URLs as plain paths). No field-level encryption in
  the application layer (relying on Postgres-at-rest/disk encryption, if
  any, which is infrastructure-level and outside this repo's visibility).
- **Still open — deliberately not implemented.** No GDPR erasure/anonymization
  endpoint. `UserService.remove` exists as a hard delete but has no exposed
  mobile API route. This was explicitly deferred: hard-delete vs.
  anonymize vs. a defined retention period is a legal/policy decision, not
  a default an engineer (or an AI agent) should pick.
- ✅ **Closed** — `CUBE_VERBOSE` (`lib/utils/constants.dart`) now defaults to
  `!kReleaseMode`: verbose by default in debug/profile (unchanged developer
  experience), **off by default in release** unless `.env` explicitly sets
  `CUBE_VERBOSE=true`. Previously it defaulted to `true` in every build
  mode, so a missing/misconfigured `.env` in a release build could log
  per-measurement result rows and full API responses.
- **Backend logging is mostly metadata-level** (user ID, test type,
  device serial, top-level result) rather than full payloads — reasonable,
  with one dev-only exception: `auth.service.ts:102` logs the user's email
  and full password-reset URL/token (explicitly dev-only, but worth
  confirming it's actually gated out of any real deployment).
- **Positive existing control:** CI (`.github/workflows/ci.yml`, `secrets`
  job) already blocks tracked patient uploads in git history and runs
  `gitleaks` — this is good practice already in place, not a gap.
- **Partially closed.** Consent (`agreementGiven`) is still collected
  *after* the measurement, at the same point in the flow as before — that
  ordering change was explicitly out of scope for this pass (bigger UX/legal
  question, deferred). What *was* closed: the checkbox now has tappable
  "Testbedingungen" / "Datenschutz" links, backed by a new public
  `get-legal-page` endpoint that exposes the `LegalPage` content that was
  already populated in the database but had no mobile-facing route at all.

## 7. Technical documentation and traceability

- `docs/regulatory/` contains only the scaffold `README.md` — **no SRS,
  risk file, traceability matrix, usability engineering file, or SOUP list
  exist yet**, exactly as that stub already flags.
- No backend- or mobile-specific regulatory documentation exists in either
  subtree (confirmed by grep for MDR/IVDR/PRRC/ISO 14971/IEC 62304/IEC
  62366-1/hazard/risk — no matches outside the Cursor rule and the doc stub
  itself).

## 8. Post-market surveillance and vigilance

- No PMS/vigilance log exists.
- As noted in §4, `AuditLog` is modeled but not populated — so there's
  currently no in-app trail that would help answer "did this bug affect a
  result a user already saw," which is the exact question section 8 of the
  rule says determines vigilance-reportability.

## 9. Change control and versioning discipline

- ✅ **Closed (baseline established)** — `CHANGELOG.md` now exists at the
  repo root; backend and mobile both have version identifiers that are
  kept in sync by convention.
- **Still open:** no dependency-update automation (Dependabot/Renovate) and
  no `npm audit` step in CI — so SOUP version drift on the regulated path
  isn't automatically surfaced. A one-time SOUP list (§3) doesn't fix this;
  it needs a recurring process.
- **New, worth tracking:** the new `.e2e-spec.ts` test files added in this
  pass (`mobile-certificate.service.e2e-spec.ts`, `get-legal-page.e2e-spec.ts`)
  are unit-style tests that only happen to run because this repo's CI
  invokes `test:e2e` (matching `*.e2e-spec.ts`) and never plain `npm test`.
  That's a slightly confusing existing convention (see
  `submit-cube-data.e2e-spec.ts`'s "CubeService metadata parsing" block for
  precedent) inherited rather than introduced here — worth deciding
  deliberately rather than by accident.

## 10. AI/agent-specific guardrails

- This is the one area with an active, verified control: `.cursor/rules/mdr-compliance.mdc`
  section 10 now requires a "Regulatory note" on any AI-agent change
  touching this rule's scope, and was verified working in a live test on
  2026-07-02 (add/revert of a `RapidTest.confidenceScore` field, twice).
  Not a repo gap — noted here for completeness against the rule's own
  section numbering.

---

## Top gaps, roughly in order of engineering priority

1. ✅ **Closed** — Certificate issuance now has a result-quality gate
   (`POSITIVE`/`NEGATIVE` only) and dedicated test coverage. *Product
   decision, confirmed before implementing, not assumed.*
2. ✅ **Closed** — Certificate mobile screens are now routed
   (`/certificates`, `/certificates/:id`) and have a nav entry + a basic
   smoke test. *Confirmed with the product owner before exposing the
   feature, since "built but unreachable" can also mean "intentionally not
   ready."*
3. ✅ **Closed** — `INVALID`/`INCONCLUSIVE` paths now have explicit test
   coverage on both backend (normalization) and mobile (badge rendering).
4. **Partially closed** — `AuditLog` is now written to on login/Cube
   submit/certificate issuance. Still open: retention, access control, and
   review process for that data are undecided.
5. **Partially closed** — Consent checkbox now links to real
   Testbedingungen/Datenschutz content. Still open: consent still happens
   *after* measurement (ordering unchanged, out of scope this pass).
6. ✅ **Closed (baseline)** — SOUP list, CHANGELOG, and version fields now
   exist. Still open: none of this is automated/enforced, so it will drift
   again without a recurring process (Dependabot, `npm audit` in CI).
7. **Still open, deliberately deferred** — positive-vs-error color overlap
   needs a real design/usability review, not an engineering color pick;
   unstyled pre-consent result text is unchanged. Both are pinned down by
   an explicit "known gap" test so they can't drift further unnoticed.
8. **Still open, deliberately deferred** — no GDPR erasure path. This needs
   a retention-policy decision (hard delete vs. anonymize vs. defined
   retention window) before it should be implemented at all — implementing
   the wrong one is worse than not implementing one yet.

None of these are "the app is non-compliant" conclusions — they're inputs
for a qualified reviewer to weigh against classification, actual clinical
risk, and documentation that may exist outside this repository. Items
marked "closed" are engineering fixes only; §1 (classification) and §2
(PRRC) — the two items that actually determine what "compliant" means for
homeDX — are unchanged and cannot be closed by a code change.

## Disclaimer (restated)

This assessment was produced by an AI coding agent via static analysis of
the repository only. It has no visibility into the Cube manufacturer's
technical documentation, any existing QMS, prior regulatory correspondence,
or organizational risk acceptance decisions. Treat every item above as a
question to bring to a qualified PRRC / regulatory affairs professional,
not as a finding that determines compliance status.
