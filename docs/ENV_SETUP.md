# Environment Variables Setup

## Backend Environment Variables

Create or update `backend/.env` with the following variables (example values shown from current dev setup):

```bash
# JWT Configuration
JWT_SECRET=your-secret-key-development

# Database
DATABASE_URL="postgresql://devuser:devpassword@localhost:5432/devdb?schema=public"

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
# API Configuration
# API_BASE_URL=http://10.0.2.2:4000  # Android emulator (Windows host)
API_BASE_URL=http://<windows-lan-ip>:4000  # Physical phone on same Wi-Fi (e.g. 192.168.178.33)
# API_BASE_URL=http://localhost:4000  # iOS simulator (macOS only)

# Stripe Configuration
# Get your publishable key from https://dashboard.stripe.com/apikeys
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
```

## Cube Android Integration

Cube data processing now runs on Android (phone/app side). The backend expects
`POST /submit-cube-data` requests containing processed result data when available.

Notes:
- Keep `API_BASE_URL` reachable from your Android device.
- If backend runs in WSL2, run `setup-wsl-port-forward.ps1` so the phone can reach port `4000`.

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




