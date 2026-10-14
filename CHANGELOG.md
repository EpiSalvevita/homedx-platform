# Changelog

homeDX did not previously track versioned changes (see
[`docs/regulatory/gap-assessment.md`](docs/regulatory/gap-assessment.md),
§9). This file starts that discipline going forward; it does not
retroactively document history before this entry.

Format: one entry per release, backend and mobile versioned
independently (`backend/package.json`, `frontend/mobile/hdx_mobile/pubspec.yaml`).

## Unreleased

**Mobile: web feedback fixes (HDX-03, HDX-05, HDX-06):**
- Web shell: below 850 px the sidebar becomes a drawer, opened from the app bar.
  Navigation taps close the drawer (`layout/web_app_shell.dart`).
- The active area is shown as text in the sidebar and the app bar:
  "Patientenbereich" or "Ärztebereich", with the account name below. Colour is
  not the only signal.
- Login and signup fields carry autofill hints (username, current-password,
  new-password). The login form saves credentials after a successful sign-in.
  A password manager round trip still needs a manual test in an approved browser.

*Regulatory note:* authentication and on-screen wording, both in scope. Failure
modes: a wrong area label shows the user the wrong role; autofill stores a
password in the wrong field. Test evidence: `test/layout/web_app_shell_test.dart`
(wide and narrow layout, drawer opens); `flutter analyze` clean. Not done: a
password manager test, a check at 320 and 390 px on a real device, and any
change to the session or cookie policy (see below). Sign-off: human review of
the wording.

**Questionnaires: resume after confirmation (handover gap 11):**
- A saved draft with answers is offered first ("Entwurf fortsetzen" or "Zurück
  zur Liste"). It is loaded only after the person confirms. Nothing is saved on
  open. Empty drafts load directly as before. There is no "start new" option,
  because clearing a draft would need a delete endpoint.
- Questionnaire intro notices grow with their text. The fixed-height card
  overflowed on narrow screens.

*Regulatory note:* a stale draft could be continued without the person noticing.
The confirmation step and the draft's revision token limit this. Test evidence:
`test/screens/questionnaires/questionnaire_resume_test.dart` (3 cases).

**Open, not changed here (HDX-04 reload and HDX-07 avatar):**
- The web session after a reload depends on the `homedx_auth` cookie. The
  cookie is `Secure` whenever `NODE_ENV=production`. The NAS compose file sets
  that, and the NAS is reached over plain HTTP. Browsers do not store `Secure`
  cookies over HTTP, so a reload loses the session while login itself still
  works. The fix is to serve the app over HTTPS
  (`deploy/nas/nginx-tls.conf.example`). Changing the cookie policy instead is
  a security decision and needs approval.
- Doctor avatar editing needs a new profile field, an upload endpoint and
  storage. The duplicate doctor profile check needs the live database.

**Questionnaires: RheumaCheck V04 catalogue (backend and mobile):**
- The questionnaire API and app now use the V04 internal-review catalogue
  (171 items: A 45, B 34, C 47, optional follow-up CFU 8, D 37) in place of
  the v6.2 catalogue. API module keys stay `A`, `B`, `C`, `CFU`, `D`.
- The follow-up (`CFU`) is split from the experience form and is shown as
  "Noch nicht vorgesehen". Only users listed in `QUESTIONNAIRE_REVIEWER_USER_IDS`
  (comma-separated user ids) can open and answer it, for internal review. No
  other user can, until an invitation mechanism exists.
- Before submit, the flow shows an answer overview with "Ändern" per section.
  The completion page shows the person's own answers. It states that this is
  neither an assessment nor a diagnosis.
- Demo build (`--dart-define=HDX_QUESTIONNAIRE_DEMO=true`): shows a labelled demo
  banner and a button that pre-fills synthetic example answers. The build never
  writes questionnaire data to a server, so synthetic data cannot reach a real
  endpoint. Default builds have no demo controls.
- Submit is strict (all visible required answers, complete matrices, rank
  bounds, scale integers 0-10, exclusive options by explicit list only). Draft
  save is lenient but still rejects unknown items and invalid values. Item ids
  and codes are returned; answer values are not.
- Hidden questions drop their answers on save, on the server and in the app.
- Patient submit requires consent (`consentStatus: yes`). This is now enforced
  server-side; the previous code did not check it.
- Saves carry a revision token (`expectedUpdatedAt`). An update to an existing
  draft is written only if it is still a draft at that revision, as one
  conditional write. A stale or missing token gets `REVISION_CONFLICT`, so
  concurrent saves cannot overwrite each other. Submit finalises at the revision
  its own save produced.
- v6.2 rows stay in the database, marked by the moduleVersion prefix. They are
  excluded from listing, drafts, readback and export. No data migration.
- Mobile: new question widgets (rank, matrix, 0-10 scale, exclusive options,
  bodymap and lab lists as multi-select). Scales start unanswered; they are never
  pre-set to 0.

*Regulatory note:* health-data capture (GDPR Art. 9). Failure modes (ISO 14971
terms): wrong branching drops or keeps answers; a stale save overwrites a newer
draft; consent bypass on submit; a demo or synthetic payload reaching a real
endpoint (server accepts only catalogue ids and types; mode is not client-set);
a matrix rating label mismatch on D11 (`nicht beurteilbar` vs help text
`kann ich nicht beurteilen`) shows a different label than the stored rating.
Test evidence: backend unit 21 (`npm test`), backend e2e 56 (incl.
`questionnaire.e2e-spec.ts`, 20 cases on a local database; 61 in total), Flutter `analyze`
clean, `flutter test` 129 passing (17 questionnaire), `flutter build web
--release` ok. Not yet done: manual check at 320/390/768 px, a real-device
test, and the review by `regulatory-reviewer`. Sign-off needed: content owner
for question wording and D11 labels, consent and DPO review, and the PRRC for
classification. No merge until these are recorded.

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
