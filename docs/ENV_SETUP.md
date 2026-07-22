# Environment Variables Setup

Canonical guide for backend and Flutter env vars, Cube Android assets, and WSL2 `API_BASE_URL` tips.

## Backend Environment Variables

Copy the template and adjust for local development:

```bash
cd backend
cp .env.example .env
```

Required and common variables:

```bash
# Required
JWT_SECRET=change-me-long-random-string

# Database (Prisma)
DATABASE_URL="postgresql://devuser:devpassword@localhost:5432/devdb?schema=public"

# Server
PORT=4000
NODE_ENV=development
APP_URL=http://localhost:4000

# CORS: comma-separated allowed origins (omit in dev = allow all)
# CORS_ORIGINS=http://localhost:8080,http://192.168.1.50:8080

# Optional: video calls (Daily.co)
# DAILY_API_KEY=
# DAILY_DOMAIN=

# Optional: payments
# STRIPE_SECRET_KEY=sk_test_...
# STRIPE_WEBHOOK_SECRET=whsec_...
# PAYPAL_CLIENT_ID=
# PAYPAL_CLIENT_SECRET=
# PAYPAL_MODE=sandbox

# Optional: push notifications (FCM)
# FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
```

`JWT_SECRET` is **required** — the server refuses to start without it.

Push delivery is optional: without `FIREBASE_SERVICE_ACCOUNT_JSON`, the backend stores in-app notifications and logs push skips.

## Flutter App Environment Variables

Create or update `frontend/mobile/hdx_mobile/.env`:

```bash
# API — must match how the device reaches the backend
# Android emulator on the same Windows machine (backend in WSL with port forwarding):
#   API_BASE_URL=http://10.0.2.2:4000
# Physical phone on the same Wi‑Fi as the PC (backend in WSL):
#   API_BASE_URL=http://<Windows Wi-Fi or Ethernet IPv4>:4000
#   Use the address from Windows ipconfig — NOT the WSL IP (172.x).
# USB debugging + adb reverse tcp:4000 (optional):
#   API_BASE_URL=http://127.0.0.1:4000
# Flutter web on the same machine as the backend:
#   API_BASE_URL=http://127.0.0.1:4000

API_BASE_URL=http://10.0.2.2:4000

# Stripe (mobile / native targets)
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here

# Optional: Firebase Cloud Messaging (native Android/iOS only)
# FIREBASE_ENABLED=true
```

After any `.env` change, rebuild the app (`flutter run` or `flutter clean && flutter run`). Hot reload does not refresh bundled env values.

### WSL2 + phone: why `API_BASE_URL` “randomly” breaks

The connectivity script only **prints** diagnostics unless you pass **`-UpdateMobileEnv`**. If your PC gets a **new DHCP address** but `.env` is stale, the phone will **time out** even when port forwarding and the backend are fine.

**Optional (Windows PowerShell, from repo root):** sync `API_BASE_URL` to your current Wi‑Fi/Ethernet IPv4, then rebuild:

```powershell
.\scripts\wsl\check-homedx-connectivity.ps1 -UpdateMobileEnv
```

For stable IPs, use a **DHCP reservation** for your PC on the router. Re-run **`scripts\wsl\setup-wsl-port-forward.cmd`** as Administrator after **WSL restarts** (WSL’s internal IP changes). See [`WSL2_PORT_FORWARDING.md`](WSL2_PORT_FORWARDING.md).

### Optional push notifications (FCM)

In-app notifications work without Firebase. For device push alerts:

1. Create a Firebase project and add an Android app with your `applicationId` (`com.homedx.app`).
2. Download `google-services.json` into `frontend/mobile/hdx_mobile/android/app/` (do **not** commit this file).
3. Set `FIREBASE_ENABLED=true` in `.env` and rebuild.
4. On the backend, set `FIREBASE_SERVICE_ACCOUNT_JSON` to the service account JSON (single line or via deploy env).

The app calls `register-push-token` when FCM returns a token. Without Firebase config, push registration is skipped.

## Cube Android test configuration (local only)

Cube assay evaluation needs vendor-specific **`.bin` config blobs** bundled into the Android APK. These files are **not in git** (see `frontend/mobile/hdx_mobile/.gitignore`).

### Where to put files

```text
frontend/mobile/hdx_mobile/android/app/src/main/assets/
```

Keep `.gitkeep` in that folder; add your local blobs beside it.

### Files used by the app

| File | Purpose |
|------|---------|
| `cube_test_config.bin` | Default/fallback Cube config (generic dev blob) |
| `CRP_250702_216.bin` | CRP assay config — required for test type id `crp` (see `lib/utils/cube_test_config_assets.dart`) |
| `cube_license.dat` | Cube SDK license (tracked in repo when present) |

Obtain `.bin` files from your Cube vendor package or device calibration export. Do not commit updated vendor blobs unless your team explicitly decides to share them.

### After adding or changing blobs

```bash
cd frontend/mobile/hdx_mobile
flutter clean
flutter run
```

If evaluation fails with “Cube config asset not found”, verify the basename matches exactly what `cubeConfigAssetBasenameForTestType()` returns for that test type.

**Pairing PIN (Android):** when Android asks for a PIN/passkey, use the **last six digits of the Cube serial number**.

## Getting API keys

### Stripe

1. https://dashboard.stripe.com → Developers → API keys
2. Copy publishable (`pk_test_…`) and secret (`sk_test_…`) keys
3. For webhooks, create an endpoint pointing to `https://your-host/webhooks/stripe` and copy `STRIPE_WEBHOOK_SECRET`

### PayPal

1. https://developer.paypal.com → Dashboard → My Apps & Credentials
2. Copy Client ID and Secret; use `sandbox` mode for testing

## Testing

### Stripe test cards

- Success: `4242 4242 4242 4242`
- Requires 3D Secure: `4000 0025 0000 3155`
- Declined: `4000 0000 0000 0002`

More: https://stripe.com/docs/testing

### PayPal sandbox

Use sandbox accounts from https://developer.paypal.com/dashboard/accounts
