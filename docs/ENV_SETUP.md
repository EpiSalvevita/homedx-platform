# Environment Variables Setup

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
# API Configuration
# API_BASE_URL=http://10.0.2.2:4000   # Android emulator (Windows host)
API_BASE_URL=http://<windows-lan-ip>:4000   # Physical phone on same Wi-Fi
# API_BASE_URL=http://127.0.0.1:4000  # Flutter web on same machine as backend

# Stripe (mobile / native targets)
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here

# Optional: Firebase Cloud Messaging (native Android/iOS only)
# FIREBASE_ENABLED=true
```

After any `.env` change, rebuild the app (`flutter run` or `flutter clean && flutter run`). Hot reload does not refresh bundled env values.

### Optional push notifications (FCM)

In-app notifications work without Firebase. For device push alerts:

1. Create a Firebase project and add an Android app with your `applicationId`.
2. Download `google-services.json` into `frontend/mobile/hdx_mobile/android/app/` (do **not** commit this file).
3. Set `FIREBASE_ENABLED=true` in `.env` and rebuild.
4. On the backend, set `FIREBASE_SERVICE_ACCOUNT_JSON` to the service account JSON (single line or file path via your deploy env).

The app calls `register-push-token` when FCM returns a token. Without Firebase config, push registration is skipped.

## Cube Android integration

Cube evaluation runs on the Android device. The app submits results with `POST /submit-cube-data`.

- **Cube Bluetooth pairing:** When Android asks for a PIN/passkey, use the **last six digits of the Cube serial number**.
- If the backend runs in WSL2, run `setup-wsl-port-forward.cmd` (Admin) so devices can reach port `4000`. See `WSL2_PORT_FORWARDING.md`.

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

## Root copy

A longer variant with Cube `.bin` asset paths and WSL2 `API_BASE_URL` troubleshooting lives at **[../ENV_SETUP.md](../ENV_SETUP.md)** in the repo root.
