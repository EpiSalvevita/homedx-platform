# Environment Variables Setup

## Backend Environment Variables

Create or update `/backend/.env` with the following variables:

```bash
# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Database
DATABASE_URL="postgresql://user:password@localhost:5432/homedx?schema=public"

# Application
APP_URL=http://localhost:4000
NODE_ENV=development

# Stripe Configuration
# Get your keys from https://dashboard.stripe.com/apikeys
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here

# PayPal Configuration
# Get your credentials from https://developer.paypal.com/dashboard/applications/sandbox
PAYPAL_CLIENT_ID=your_paypal_client_id_here
PAYPAL_CLIENT_SECRET=your_paypal_client_secret_here
PAYPAL_MODE=sandbox  # Use 'live' for production
```

## Flutter App Environment Variables

Create or update `frontend/mobile/hdx_mobile/.env` with the following variables:

```bash
# API — must match how the device reaches the backend (see below)
# Android emulator on the same Windows machine (backend in WSL with port forwarding):
#   API_BASE_URL=http://10.0.2.2:4000
# Physical phone on the same Wi‑Fi as the PC (backend in WSL):
#   API_BASE_URL=http://<Windows Wi-Fi or Ethernet IPv4>:4000
#   Use the address from Windows ipconfig — NOT the WSL IP (172.x / 172.26.x).
# USB debugging + adb reverse tcp:4000 (optional):
#   API_BASE_URL=http://127.0.0.1:4000

API_BASE_URL=http://10.0.2.2:4000

# Stripe Configuration
# Get your publishable key from https://dashboard.stripe.com/apikeys
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
```

### WSL2 + phone: why `API_BASE_URL` “randomly” breaks

The connectivity script **`check-homedx-connectivity.ps1`** only **prints** diagnostics unless you pass **`-UpdateMobileEnv`**. It does **not** change the app by itself. If your PC gets a **new DHCP address** (e.g. was `192.168.2.35`, now `192.168.178.33`) but `.env` is stale, the phone will **time out** even when port forwarding and the backend are fine.

**After any `.env` change**, do a **full rebuild** (`flutter run` from a clean stop, or `flutter clean && flutter run`). Hot reload does not refresh bundled `.env`.

**Optional (Windows PowerShell, repo root):** sync `API_BASE_URL` to your current Wi‑Fi/Ethernet IPv4, then rebuild:

```powershell
.\check-homedx-connectivity.ps1 -UpdateMobileEnv
```

For stable IPs, use a **DHCP reservation** for your PC on the router (or a fixed IPv4 on the adapter). Re-run **`setup-wsl-port-forward.cmd`** after **WSL restarts** (WSL’s internal IP changes). See `docs/WSL2_PORT_FORWARDING.md`.

## Getting API Keys

### Stripe
1. Go to https://dashboard.stripe.com
2. Sign up or log in
3. Navigate to **Developers** → **API keys**
4. Copy your **Publishable key** (starts with `pk_test_` for test mode)
5. Copy your **Secret key** (starts with `sk_test_` for test mode)
6. For production, use keys starting with `pk_live_` and `sk_live_`

### PayPal
1. Go to https://developer.paypal.com
2. Sign up or log in
3. Navigate to **Dashboard** → **My Apps & Credentials**
4. Create a new app or use an existing one
5. Copy the **Client ID** and **Secret**
6. For production, switch to **Live** mode and get production credentials

## Testing

### Stripe Test Cards
- Success: `4242 4242 4242 4242`
- Requires 3D Secure: `4000 0025 0000 3155`
- Declined: `4000 0000 0000 0002`

More test cards: https://stripe.com/docs/testing

### PayPal Sandbox
- Use sandbox accounts from https://developer.paypal.com/dashboard/accounts
- Create buyer and seller accounts for testing



