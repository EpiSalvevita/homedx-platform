# HomeDX App Functionality Matrix

Snapshot of what exists today in the backend vs the Flutter app, plus a short backlog.

**API:** REST `POST` under `/gg-homedx-json/gg-api/v1`. See `APPOINTMENTS_VIDEO.md` for appointments and `frontend/mobile/hdx_mobile/PAYMENT_INTEGRATION.md` for payments.

## Current state

### Authentication & user management

- **Backend:** `login`, `register-account`, `get-user-data`, `update-user-data`
- **App:** login, signup, profile view/edit, global 401 → logout
- **Gap:** password reset, account deletion, profile image upload

### Rapid test & Cube flow

- **Backend:** `get-test-type-list`, `add-test`, `get-last-test`, `submit-cube-data`, `add-rapid-test-photo`, `add-rapid-test-video`, `add-identification-photo`, `get-live-token`
- **App:** test selection, Cube BLE scan/connect, on-device evaluation, result submission and display
- **Gap:** end-to-end manual test flow with all media uploads; test history list; live session UI

### Appointments & video

- **Backend:** doctors, slots, book/list/cancel, Daily.co tokens (`get-doctors`, `get-doctor-slots`, `book-appointment`, etc.)
- **App:** patient booking and list; doctor web dashboard and video join — see `APPOINTMENTS_VIDEO.md`

### RheumaCheck Anamnesefragebögen (A–D)

- **Backend:** `get-questionnaire-modules`, `get-questionnaire-definition`, `save-questionnaire-draft`, `submit-questionnaire`, `get-questionnaire-submission`, `export-questionnaire-submissions` (ADMIN)
- **Data:** `QuestionnaireSubmission` model (module A/B/C/D, answers JSON, draft/submitted, optional `linkedRapidTestId`)
- **App:** JSON-driven wizard; hub at `/questionnaires` (patient A/C) and `/doctor/questionnaires` (doctor B/D)
- **Flow hooks:** Bogen A offered before RheumaCheck test; Bogen C after test result; B/D on doctor dashboard
- **Regulatory (v1):** capture-only — no automatic diagnosis or care routing; consent required for patient forms; audit logs store metadata only
- **Gap:** CSV export UI; GDPR erasure; FHIR export

### Payments

- **Backend:** `get-payment-amount`, `create-payment`, `create-stripe-payment-intent`, `create-paypal-order`, `update-payment`; webhooks `/webhooks/stripe`, `/webhooks/paypal`
- **App:** shop/checkout via `PaymentService` (Stripe SDK, PayPal WebView)
- **Gap:** payment history UI (no list REST route yet); refunds; receipt polish

### Certificates

- **Backend:** certificate services (PDF, QR, storage) — no mobile REST routes yet
- **App:** not wired in UI
- **Gap:** view/download/share certificates

### Licenses & coupons

- **Backend:** license services in Nest — no mobile REST routes yet
- **App:** not wired
- **Gap:** enter code, view active licenses, expiry warnings

### Test kits

- **Backend:** test kit services — no mobile REST routes yet
- **App:** not wired
- **Gap:** serial scan, assignment, usage tracking UI

### Notifications

- **Backend:** notification services — no mobile REST routes yet
- **App:** basic UI; push not wired
- **Gap:** inbox, badges, push notifications

### File uploads

- **Backend:** multipart routes for test photo/video and ID photos
- **App:** partial (screens exist; full submission flow still evolving)
- **Gap:** camera/gallery UX, progress, retry

### System & legal

- **Backend:** `get-be-status-flags`; legal page services (no mobile REST routes for legal content yet)
- **App:** landing/about, settings/legal screens
- **Gap:** load legal text from API; terms acceptance on signup

### Bluetooth & Cube

- **Pairing PIN (Android):** last six digits of Cube serial number
- **App:** Cube SDK path on Android; generic BLE helpers for non-Cube devices
- **Flow:** Cube SDK → Flutter → `submit-cube-data` → `RapidTest` in DB

## Backlog (prioritized)

Rough order for product work — not a commitment.

**High**

1. Complete rapid-test submission UI (media + review step)
2. Certificate viewing/download once REST routes exist or admin API is exposed
3. Payment history endpoint + UI
4. Push notifications + notification REST API for mobile

**Medium**

5. License/coupon activation UI
6. Test kit assignment UI
7. Dashboard summary (recent tests, notifications count)
8. Legal pages from backend content
9. QR scanner (test kit / certificate codes)

**Lower**

10. Offline queue for uploads
11. Biometric login
12. Two-factor authentication

## Technical notes

- Mobile API base: `/gg-homedx-json/gg-api/v1/*`
- Auth: `Authorization: Bearer <token>` or `x-auth-token`
- Uploads: `multipart/form-data` on mobile REST routes
- Timestamps: milliseconds (Unix) where returned by the API
- Many admin/domain features exist only in Nest **services** today; expose REST on `mobile.controller.ts` before wiring Flutter UI
