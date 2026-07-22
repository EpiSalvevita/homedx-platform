# HomeDX App Functionality Matrix

Snapshot of what exists today in the backend vs the Flutter app, plus a short backlog.

**API:** REST `POST` under `/gg-homedx-json/gg-api/v1`. Controllers live in `backend/src/controllers/mobile-*.controller.ts`. See `APPOINTMENTS_VIDEO.md` for appointments and `frontend/mobile/hdx_mobile/PAYMENT_INTEGRATION.md` for payments.

## Current state

### Authentication & user management

- **Backend:** `login`, `register-account`, `request-password-reset`, `reset-password`, `get-user-data`, `update-user-data`, `init-authentication` (web session probe), `unset-authentication` (clear auth cookie)
- **App:** login/signup (patient + doctor), forgot/reset password, profile view/edit, global 401 → logout; web uses cookie + `init-authentication`
- **Gap:** account deletion, profile image upload

### Rapid test & Cube flow

- **Backend:** `get-test-type-list` (hardcoded catalog), `add-test`, `get-last-test`, `submit-cube-data`, media uploads (`add-rapid-test-photo`, `add-rapid-test-video`, `add-identification-photo`), `finalize-test-submission`
- **App:** test selection, Cube BLE scan/connect (Android), on-device evaluation via `lib/features/cube/cube_service.dart`, result submission/display; web shows Cube stubs
- **Gap:** fuller end-to-end media + review UX; richer test history list (beyond last test); DB-driven test catalog

### Appointments & video

- **Backend:** `get-doctors`, `get-doctor-slots`, `book-appointment`, `list-appointments`, `get-appointment`, `cancel-appointment`, `get-video-call-token`, doctor availability get/set
- **App:** patient booking/list/detail; doctor web dashboard, availability, video join — see `APPOINTMENTS_VIDEO.md`

### RheumaCheck Anamnesefragebögen (A–D)

- **Backend:** `get-questionnaire-modules`, `get-questionnaire-definition`, `save-questionnaire-draft`, `submit-questionnaire`, `get-questionnaire-submission`, `export-questionnaire-submissions` (ADMIN)
- **Data:** `QuestionnaireSubmission` (modules A–D, answers JSON, draft/submitted, optional `linkedRapidTestId`); definition JSON under `backend/data/questionnaires/`
- **App:** JSON-driven wizard; hub at `/questionnaires` (patient A/C) and `/doctor/questionnaires` (doctor B/D)
- **Flow hooks:** Bogen A before RheumaCheck test; Bogen C after result; B/D on doctor dashboard
- **Regulatory (v1):** capture-only — no automatic diagnosis or care routing; consent required for patient forms; audit logs store metadata only
- **Gap:** CSV export UI; GDPR erasure; FHIR export

### Payments

- **Backend:** `get-payment-amount`, `create-payment`, `get-payment`, `list-payments`, Stripe intent/confirm, PayPal create/capture, `update-payment`; webhooks `/webhooks/stripe`, `/webhooks/paypal`
- **App:** shop/checkout via `PaymentService` (Stripe SDK, PayPal WebView); payment history screen
- **Gap:** refunds; receipt polish; shop catalog still partly mocked (`shop_service.dart`)

### Certificates

- **Backend:** `list-certificates`, `get-certificate`, `get-certificate-pdf` (`MobileCertificateService`; auto-issue on certifiable Cube results)
- **App:** certificates list + detail (PDF download path)
- **Gap:** share UX polish; types beyond `TEST_RESULT` unused

### Licenses & coupons

- **Backend:** Prisma `License` model retained for data continuity — **no active Nest service or mobile REST** (GraphQL-era `LicenseService` removed). Distinct from Cube SDK device license (`.dat` / AAR).
- **App:** profile shows Cube device license validity only (SDK), not Nest license keys
- **Gap:** product decision if license/coupon codes are needed; do not reintroduce without a clear product path

### Test kits

- **Backend:** kits auto-created on Cube/test paths; no dedicated mobile “manage kits” API
- **App:** not a standalone kit-management UI
- **Gap:** serial scan, assignment, usage tracking UI (only if product needs it)

### Notifications

- **Backend:** `list-notifications`, `get-unread-notification-count`, `mark-notification-read`, `mark-all-notifications-read`, `register-push-token`
- **App:** in-app inbox; push registration optional (Firebase may be off)
- **Gap:** reliable FCM/APNs in all builds; richer badge/deep-link behavior

### File uploads

- **Backend:** multipart routes for test photo/video and ID photos; finalize step
- **App:** screens exist; submission flow still evolving
- **Gap:** camera/gallery UX, progress, retry

### System & legal

- **Backend:** `get-be-status-flags`; `get-legal-page` (privacy, terms, impressum, cookies)
- **App:** landing/about; legal screens load from API by type
- **Gap:** explicit terms acceptance gate on signup (if product/legal requires it)

### Bluetooth & Cube

- **Pairing PIN (Android):** last six digits of Cube serial number
- **App:** Cube SDK path on Android (`com.homedx.app`); web stubs intentional
- **Flow:** Cube SDK → Flutter → `submit-cube-data` → `RapidTest` in DB

## Backlog (prioritized)

Rough order for product work — not a commitment.

**High**

1. Complete rapid-test submission UI (media + review step)
2. Harden push (Firebase) across release builds
3. Shop catalog from real backend data (replace mock `shop_service`)
4. Test history list (not only last test)

**Medium**

5. Refunds / receipt polish
6. Dashboard summary (recent tests, unread notification count)
7. Terms acceptance on signup (if required)
8. QR scanner (kit / certificate) if product needs it

**Lower**

9. Offline queue for uploads
10. Biometric login
11. Two-factor authentication
12. License/coupon product (only after product decision)

## Technical notes

- Mobile API base: `/gg-homedx-json/gg-api/v1/*`
- Auth: `Authorization: Bearer <token>` or `x-auth-token`; web also uses HTTP-only cookie
- Uploads: `multipart/form-data` on mobile REST routes
- Timestamps: milliseconds (Unix) where returned by the API
- Nest wiring: feature modules under `backend/src/modules/`; thin `app.module.ts`
- Flutter layout: `lib/core/` (API + constants), `lib/features/cube/`, other domains still under `lib/services/` + `lib/screens/`
