# Changelog

homeDX did not previously track versioned changes (see
[`docs/regulatory/gap-assessment.md`](docs/regulatory/gap-assessment.md),
§9). This file starts that discipline going forward; it does not
retroactively document history before this entry.

Format: one entry per release, backend and mobile versioned
independently (`backend/package.json`, `frontend/mobile/hdx_mobile/pubspec.yaml`).

## Unreleased

- **Backend: dependency upgrade within Nest 11.x and test tooling.** `@nestjs/common|core|platform-express|testing` 11.1.x to 11.2.11, `@nestjs/jwt` 11.0.0 to 11.0.2, `jest` 30.5.2, `ts-jest` 29.4.15, `@types/express` 5.0.6. Nest 12 (ESM-only) is deliberately not adopted. Resolved transitive runtime changes: express 5.1.0 to 5.2.1, body-parser 2.2.0 to 2.4.0, path-to-regexp 8.2.0 to 8.4.2, qs to 6.17.1, multer 2.0.2 to 2.5.0, file-type to 21.3.4, jsonwebtoken 9.0.2 to 9.0.3, jws 3.2.2 to 4.0.1, jwa 1.4.2 to 2.0.1 (recorded in `docs/regulatory/soup-list.md`).
  - *Security result:* production `npm audit` high 13 to 7, moderate 14 to 10, critical 0. Includes fixes for the `@nestjs/core` injection advisory GHSA-36xv-jgw5-4q75, multer/body-parser/path-to-regexp/qs/file-type DoS, and jws HMAC verification GHSA-869p-cjfg-cm3x. Dev-only moderates rose (jest 30.5 chain; not shipped).
  - *Behavior tightening:* the global `ValidationPipe` in Nest 11.2 strips `constructor`/`prototype` keys at any depth and rejects non-object bodies for DTOs with rules. Only the free-form questionnaire `answers` (`backend/src/dto/mobile/questionnaire.dto.ts`) could be affected, and only if a key is literally named `constructor` or `prototype`. jws 3 to 4 only changes the jwa major and rejects empty HMAC secrets; `getJwtSecret()` already throws on empty.
  - *Regulatory note:* framework and auth SOUP changed; no application code, result logic, thresholds, status mapping or wording changed. Failure modes: request-handling regression (dropped or mis-handled result), JWT validation regression (lockout or bypass). Test evidence: all e2e suites incl. new `jwt-auth-negative` (expired, wrong secret, `alg:none`, HS512, tokenVersion mismatch all 401; valid token 2xx) and the media-upload suites from the upload fix. Sign-off was required (auth SOUP incl. transitive jws/jwa major); human sign-off given by the product owner 2026-11-19. The PRRC/QMS owner decides whether a formal SOUP re-assessment record is needed.
- **Backend: fix media uploads (`add-rapid-test-photo`, `add-rapid-test-video`, `add-identification-photo`).** Since 2026-06-22 (commit 10a4ee83) no upload could succeed, for two independent reasons on `main`: (1) `FileUploadService.uploadFile()` expected a GraphQL-upload object (`createReadStream()`) but the controllers pass a multer file, so every call threw and returned "File upload failed"; (2) `RapidTestMediaUploadDto` required `fileExtension`, which the Flutter client never sends, so requests were rejected at validation. In addition, no upload limits were ever applied: `MulterModule.register(...)` in `AppModule` is not global and `TestsModule` never imported it, so `FileInterceptor` ran with multer defaults (the `dest` there never took effect either; uploads were already memory-backed). Changes: the service now takes the multer file; `fileExtension` is optional and ignored (extension is derived from the detected type only); explicit limits per interceptor (images 10 MB, video 100 MB, 1 file, 5 fields, 1 KiB per field); the dead `MulterModule` registration is removed; `rapidTestId` is required and its ownership is verified before anything is written; the stored file is removed if attaching it fails; object names are `<folder>_<uuid><ext>` written with exclusive create (the former `<folder>_<Date.now()>` name could collide and overwrite another person's file once storage worked); magic-byte detection now covers MP4/MOV (`ftyp` brands) so videos can pass (previously only JPEG/PNG/GIF/WebM were detectable); photo endpoints accept images only and the video endpoint videos only; video uses disk storage in one fixed private 0700 temp dir `os.tmpdir()/homedx-video` (not `uploads/`); the temp file is deleted when the response closes (which also fires when the client aborts mid-upload, a case multer 2.0.2 does not clean up itself) and before the response on the normal path, a startup sweep removes temp files older than 15 minutes and stale legacy `homedx-video-*` dirs, and a failed copy into `uploads/videos` removes the partial destination file; errors are logged by code/name only; `deploy/nas` mounts a named volume at `/app/uploads` (Dockerfile pre-creates the directory for the `node` user). Unchanged: magic-byte validation against an allow-list, `uploads/<folder>/` location (gitignored `backend/uploads/`), sanitized error text, response shape. HEIC is not detected or allowed (follow-up). *Regulatory note:* (1) regulatory-relevant: stores test photos/videos and ID photos used as test evidence (GDPR Art. 9 health data and ID documents). (2) Failure modes: silent loss of media evidence since 2026-06-22 (internal testing only per the product owner, no vigilance report); latent defects that would have surfaced once storage worked and are fixed here: file name collisions (PHI mix-up or overwrite between users), orphaned PHI from uploads without an ownership check, unlimited upload size. Test results and certificates do not depend on these attachments: the certificate service never reads `photoUrl`/`videoUrl`/`identityCard*Url`, the mobile app does not read them, and the attach step only sets those columns. (3) Test evidence: `backend/test/media-upload.e2e-spec.ts` (exact client field set; stored bytes and attach call; MP4/MOV/WebM; concurrent uploads keep distinct names and own bytes; wrong field, non-media bytes, wrong kind, oversize image/video, foreign and missing `rapidTestId` store nothing and leave no temp file; stored file removed when attach fails; client abort mid-upload leaves no temp file) and `backend/test/media-upload-module.e2e-spec.ts` (real `TestsModule`, oversize rejected by the interceptor limit); synthetic bytes only. (4) Sign-off: human and DPO sign-off required before merge (PHI storage path, location, volume); PRRC input not needed for result logic as none changed. Follow-ups: no retention/deletion policy for stored media exists (see `docs/regulatory/gap-assessment.md`); stored files are unencrypted at rest on the volume; HEIC support.

**Mobile (Android): MainActivity now extends FlutterFragmentActivity; Material Components launch/normal themes (Stripe PaymentSheet fix):**
- `flutter_stripe`'s Android plugin (stripe_android 11.5.0, `StripeAndroidPlugin.onAttachedToActivity`) records an initialization error unless the host activity is a `FlutterFragmentActivity` with an AppCompat/MaterialComponents theme. `MainActivity` extended `FlutterActivity` and the themes descended from `@android:style/Theme.*`, so PaymentSheet could not initialize on Android. `MainActivity` now extends `FlutterFragmentActivity` (`configureFlutterEngine`/`CubeBridge` creation and `onDestroy` dispose unchanged); `LaunchTheme`/`NormalTheme` (light and night) now descend from `Theme.MaterialComponents.DayNight.NoActionBar`, existing items preserved, status/navigation bar colors pinned to black (as before). `android.enableR8.fullMode=false` added (flutter_stripe README, release builds) and `com.google.android.material:material:1.6.0` declared explicitly; SOUP list updated.

*Regulatory note:* (1) Regulatory-relevant: yes. `MainActivity` hosts the Cube bridge (regulated result path), so the host activity's lifecycle changes; payment flow is also affected. (2) Failure modes (ISO 14971): Cube bridge not registered or EventChannel lifecycle differing under `FlutterFragmentActivity` leading to no or dropped result; activity recreation mid-run; PaymentSheet still failing (generic payFailed). Payments stay server-authoritative; no result logic, thresholds or wording changed. No result or certificate a user saw is affected (host-activity change only; not a vigilance item). Card payment on Android may have always failed before this fix: a human should check payment logs and user complaints for follow-up blocked after positive results. (3) Test evidence: local Android builds fail on this machine's network (TLS error downloading the Flutter engine jar), but the new `Android` CI workflow (`.github/workflows/android.yml`) builds `flutter build apk --debug` and `--release` (R8, enableR8.fullMode=false) successfully (about 11.5 min); `flutter analyze` clean and `flutter test` 152 passed; device regression tests required and listed in the PR (Stripe test-mode payment, Cube end-to-end, activity recreation, dark mode/splash). CI Android build compiles the Kotlin/themes/Gradle changes; runtime behavior still needs device tests. (4) Human sign-off needed after on-device testing, before merge. Human sign-off given by the product owner 2026-11-19.

**Mobile: flutter_dotenv 5.2.1 to 6.0.1 (dependabot):**
- Test-only code change: `dotenv.testLoad(fileInput:)` renamed to `dotenv.loadFromString(envString:)` in `test/widget_test.dart` and `test/services/cube_service_test.dart`. `docs/regulatory/soup-list.md` range bumped to ^6.0.1. Runtime usage (`dotenv.load(fileName: '.env')`, `dotenv.env[...]`) unchanged; no use of `clean()`, `getInt`, `getBool` or `isOptional`.

*Regulatory note:* runtime-config SOUP version bump, no app code, result logic or wording changed; `flutter analyze` and `flutter test` green; no sign-off needed beyond routine SOUP list update.

**Mobile: flutter_lints 5 to 6 (dependabot) with lint fixes:**
- `use_null_aware_elements` (`if (x != null) 'k': x` to `'k': ?x`) in `api_service.dart`, `payment_service.dart`, `questionnaire_service.dart` and one test; `unnecessary_underscores` in builders (`(_, __)` to `(_, _)`).

*Regulatory note:* regulatory-relevant surface: the rewrite touches the `submit-cube-data` payload (`ApiService.submitCubeData`, `result`/`resultData`/`rawData` keys) and the payment/questionnaire request maps. Failure mode (ISO 14971): a dropped `result` or `resultData` key would mean a lost Cube result. `'k': ?x` is equivalent to `if (x != null) 'k': x` by Dart null-aware element semantics (key omitted when null, otherwise the value as-is). Now covered by new request-body tests (`test/core/request_body_test.dart`, 9 tests, real `ApiService` and service methods with a mocked HTTP client): unset keys are absent (not null), set keys carry exact values incl. `resultData` list and `result` string. The `(_, __)` / `(_, __, ___)` to `(_, _)` / `(_, _, _)` builder renames only rename unused parameters. Added a `@visibleForTesting` `client` parameter to the `ApiService` constructor (default unchanged). Regulatory review completed 2026-11-19 after the request-body tests were added: no PRRC sign-off required.

- **Mobile (Android): Cube license file no longer tracked in git.** `android/app/src/main/assets/cube_license.dat` is removed from the index and gitignored; the local copy stays in place for builds. Developers obtain it from BIOSYNEX or the team's secure store (`docs/ENV_SETUP.md`). *Regulatory note:* no code or result logic changed. A missing license makes `licenseValid` false and blocks Cube tests (fail closed). The file remains in git history; rotation or history purge is a separate decision with BIOSYNEX.

**Mobile: iOS Bluetooth permission flow and platform-neutral wording:**
- `requestPermissions()` now requests `Permission.bluetooth` on iOS (and no location); Android flow unchanged. Cube-not-available, license-hint and BT-timeout wording no longer names Android only (DE+EN).

*Regulatory note:* permission/connectivity-adjacent, no result logic or result/certificate wording touched. Failure mode: denied permission blocks scan (fail closed, error shown), no result affected. Tests: `test/services/bluetooth_permissions_test.dart` (iOS granted/denied/permanentlyDenied, location never asked; Android sequence unchanged), `flutter analyze` and `flutter test` green. The iOS permission path only works once `ios/project-setup` (Podfile `PERMISSION_BLUETOOTH` macro, `NSBluetoothAlwaysUsageDescription`) lands, and Cube tests on iOS need the separate native bridge PR. iOS adapter-state check now waits (3 s, fail closed) for the first non-unknown state. On-device iOS verification pending.

**Mobile: iOS project setup (Podfile, iOS 17, bundle id, CI):**
- Min iOS 13 to 17, bundle id `com.example.hdxMobile` to `com.homedx.app`, Podfile with `PERMISSION_BLUETOOTH` macro only (no location on iOS), optional local `CubeReader` pod (proprietary SDK not in git), `NSBluetoothAlwaysUsageDescription`, `bluetooth-central` background mode (timed evaluations up to ~20 min may continue with the screen locked), new `ios` CI job (path-filtered), `docs/IOS_SETUP.md`.

*Regulatory note:* project configuration only; no result logic, thresholds, status mapping or result/certificate wording changed. iOS 13-16 devices are no longer supported (compatibility change). Usage string states that the app receives the result determined by the Cube. Tests: CI `ios` job (simulator build and RunnerTests). On-device Cube verification pending (needs the native bridge PR and a Mac).

**iOS: Cube bridge for the CubeReader SDK (`ios/Runner/Cube/`):**
- New Swift bridge that serves the same `com.homedx.cube/analysis` method
  channel and `com.homedx.cube/events` event channel as the Android
  `CubeBridge`, so `cube_service.dart` runs unchanged on iOS. All 14 methods,
  the `invalid_args` / `missing_asset` / `open_failed` error codes and the
  event shapes match Kotlin. `class` is passed verbatim and `value` is the
  SDK's formatted string.
- **Status-mapping difference from Android (open question for PRRC and
  BIOSYNEX):** the iOS SDK only exposes `Result.isValid` (Bool). iOS sends
  `validity` 0 when it is true and 3 ("Ungültig") otherwise, as an Int.
  Android reports 0–4, so "Kein Wert" (1), "Unendlich" (2) and "Gerät
  abgelaufen" (4) never appear on iOS. What `isValid` covers in CubeReader
  1.3.0 (expiry, missing value) is undocumented.
- Wrong-measurement guard: `startEvaluation` snapshots the stored
  measurements and captures the connected Cube's serial and clock (refused
  with `device_unknown` if either is unknown). The run's measurement is
  identified only after `measurementEnd` and before any DB read starts: exactly
  one new row, same Cube serial, `deviceDate` not earlier than the captured
  Cube clock minus 2 s. A DB read never identifies a measurement, because it
  can import old Cube-stored ones. A DB read with no identified measurement,
  several or zero candidates, a serial or date mismatch, or a missing or
  duplicated pinned row all emit `MT_ERROR` 99 and no `IM_MEASURE_COUNT`.
  `selectMeasurement` accepts only the identified measurement
  (`measurement_mismatch`). A run ends after `IM_MEASURE_COUNT`, so later SDK
  messages cannot produce a stale `IM_MEASUREMENT_DONE`. When the SDK refuses
  `startEvaluation` or `readDeviceDatabase` during a run, the bridge emits
  `MT_ERROR` 98.
- Conservative until verified on a device: `DeviceError` is sent with
  `msgData` 0 (its raw value may be an ordinal, not the firmware code Dart's
  texts expect), and no `IM_TIMER_RUNNING` countdown is sent, because the
  meaning of `InfoMessage.data` is undocumented.
- The CubeReader view model is created on the first Cube channel call rather
  than at app launch, which avoids a Bluetooth prompt without context.
- Without `CubeReader.xcframework` (CI, public checkouts) the app builds with
  a fail-closed fallback: license invalid, every device call returns
  `sdk_unavailable`.

*Regulatory note:* regulatory-relevant (transport of Cube results to the
screen and backend on a new platform). No thresholds or class mapping in the
app, but the validity mapping above is a status-mapping difference from
Android. ISO 14971 failure modes:
- A wrong or old measurement attached to a run: mitigated by the guard, which
  identifies only before any DB read and checks serial and time, and by the
  selection lock.
- A result dropped or delayed: fails closed with an error, nothing submitted.
- A result field altered in transit: class and value verbatim, validity Int
  only, covered by tests.
- Wrong device serial: taken from the identified measurement, which must match
  the connected Cube.

Test evidence: XCTest `RunnerTests/CubeBridgeTests.swift` in the CI `ios` job
with a fake SDK, covering the mapping, the guard (including DB-import paths
without `measurementEnd`, serial and date mismatch, duplicates, a removed pin
and back-to-back runs), config resolution and listen/cancel. Missing: the
real-SDK adapter compiles only on a Mac with the SDK, and the on-device
checklist in the PR is pending. Sign-off: human/PRRC sign-off required before
merge and before iOS results are used.
- Follow-ups in the same PR:
  - The iOS CI workflow now writes an `.xcresult` bundle and uploads the
    summary as a 90-day artifact (test evidence). It fails unless the result
    is "Passed" with at least 46 tests and no failures.
  - The SOUP list records CubeReader 1.3.0 (iOS).
  - `BluetoothProvider` no longer shows "Bluetooth deaktiviert" on a cold iOS
    launch: it waits for a settled adapter state and follows adapter-state
    updates on iOS. Android is unchanged. Dart tests were added for both.

**Backend Docker image: include the questionnaire catalogue:**
- `backend/Dockerfile` now copies `backend/data/` into the image. The
  questionnaire service loads the RheumaCheck V04 catalogue from
  `data/questionnaires/` at runtime; images built from `main` lacked it. The
  NAS preview already carried this line as an uncommitted local edit.

*Regulatory note:* relevant (availability of the questionnaire in deployed
backends), no logic, wording or catalogue content changed. Failure mode: a
backend built without the catalogue cannot serve the questionnaire (fails
loudly, no wrong result). Test evidence: image built locally from this branch;
the catalogue file named in `questionnaire.service.ts` exists at
`/app/data/questionnaires/` and parses as JSON. Backend logic not exercised
(unchanged). Sign-off: not needed (build
packaging only).

**Docs: regulatory and import material reorganised (paths only):**
- `FACHLICHE_PRUEFPUNKTE_V04.md` moved to `docs/regulatory/` and added to the
  regulatory README index as an internal-review draft.
- Questionnaire handover sources moved from `docs/imports/` to `work/imports/`;
  path references in docs and code comments updated.

*Regulatory note:* in-scope paths (`docs/regulatory/**`, a comment in
`backend/src/utils/questionnaire-v04-engine.ts`), but no logic, wording or document content changed.
Failure mode: a broken reference makes the review points hard to trace;
checked with `git grep` for the old paths (no hits outside this
changelog). Test evidence: `flutter
analyze` clean, `flutter test` passes. Sign-off: not needed for the move; the
document's open clinical items still need PRRC/clinical sign-off.

**Mobile: certificates renamed to "Dokumente" (UI wording only):**
- Home quick-action tile label and list title: "Zertifikate" → "Dokumente" (EN: "Documents").
- Detail title, tap hint, load error, empty state, not-found and PDF hint
  reworded to "Dokument(e)" (EN: "Document(s)"). Keys unchanged, so no logic changed.
- Marketing text on the landing page is not changed.

*Regulatory note:* wording on certificate screens, in scope (IEC 62366-1 use
error). Failure mode: a user does not recognise "Dokumente" as the place for
their test certificate and cannot find or share it. No result, threshold or
certificate content changed. Test evidence: `gen-l10n` and `flutter build web`
pass; the new strings are in the bundle; `test/screens/certificates_list_screen_test.dart`
pins the list title ("Dokumente" / "Documents") and the empty state. Not done:
a check on a logged-in session, and a test of the home tile label. Sign-off: human or PRRC review of
the wording is still pending. The change was merged to `main` in `567fc74a`
without a recorded review.

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

**Backend: legal pages seed (Impressum, Datenschutz, AGB):**
- `npm run seed:legal` loads the German legal pages from `backend/prisma/legal-content/`. Before this, the `LegalPage` table had no rows, so the pages were empty.
- The Impressum is the salvevita Managementgesellschaft mbH text. Its contact e-mail and phone are still placeholders.
- Datenschutz and AGB are generated drafts, marked as drafts in the text. They need review by the data protection officer and legal advice before publication.
- Do not run the seed against production without that review.

**Mobile: landing page language switch:**
- The landing page now translates its hero, navigation, doctor cards, doctor
  call-to-action and footer. Before, only the story section followed the
  language switch. German text is unchanged.
- Test evidence: `test/l10n/marketing_strings_test.dart`. Marketing copy only,
  no regulatory impact.

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
