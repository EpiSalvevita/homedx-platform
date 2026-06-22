# Payment Integration Guide

Payments use the **mobile REST API** and payment-provider SDKs on the client. Card data never touches your servers.

**Flutter client:** `lib/services/payment_service.dart`  
**Backend:** `MobilePaymentService` + routes in `mobile.controller.ts`  
**Webhooks:** `POST /webhooks/stripe`, `POST /webhooks/paypal`

All mobile payment routes require JWT auth (`Authorization: Bearer …` or `x-auth-token`).

Base path: `/gg-homedx-json/gg-api/v1`

## Payment methods

### 1. Credit card (Stripe)

**Package:** `flutter_stripe`

**Flow:**

1. App calls `POST create-payment` → payment record (`PENDING`)
2. App calls `POST create-stripe-payment-intent` with `paymentId`, `amount`, `currency` → `clientSecret`
3. Stripe SDK confirms the PaymentIntent on the device
4. App calls `POST update-payment` with `paymentId`, `status`, optional `transactionId`
5. Optionally Stripe webhook (`payment_intent.succeeded`) updates status server-side

**Setup:**

Backend `backend/.env`:

```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

Flutter `frontend/mobile/hdx_mobile/.env`:

```env
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

Stripe is initialized in `lib/config/stripe_init.dart` (skipped on web where not configured).

### 2. PayPal

**Package:** `webview_flutter`

**Flow:**

1. App calls `POST create-payment` (or reuses an existing `paymentId`)
2. App calls `POST create-paypal-order` with `paymentId`, `amount`, `currency`, optional `returnUrl` / `cancelUrl` → `orderId`, `approvalUrl`
3. User completes checkout in PayPal WebView
4. App calls `POST update-payment` with `paymentId` and completion status
5. PayPal webhook can confirm capture server-side

**Setup:**

```env
PAYPAL_CLIENT_ID=...
PAYPAL_CLIENT_SECRET=...
PAYPAL_MODE=sandbox
```

### 3. SEPA bank transfer

Manual flow: create payment with `PENDING`, user transfers offline, admin marks `COMPLETED` (no SDK).

## REST endpoints

### Get payment amount

`POST /gg-homedx-json/gg-api/v1/get-payment-amount`

```json
{}
```

Response (example):

```json
{
  "success": true,
  "amount": 29.99,
  "discount": 0,
  "discountType": null,
  "reducedAmount": 29.99
}
```

### Create payment

`POST /gg-homedx-json/gg-api/v1/create-payment`

```json
{
  "amount": 29.99,
  "currency": "EUR",
  "paymentMethod": "CREDIT_CARD",
  "rapidTestId": "optional-rapid-test-id"
}
```

Response: `{ "success": true, "payment": { "id", "status", ... } }`

### Create Stripe PaymentIntent

`POST /gg-homedx-json/gg-api/v1/create-stripe-payment-intent`

```json
{
  "paymentId": "payment-uuid",
  "amount": 29.99,
  "currency": "EUR"
}
```

Response: `{ "success": true, "clientSecret": "pi_..._secret_..." }`

### Create PayPal order

`POST /gg-homedx-json/gg-api/v1/create-paypal-order`

```json
{
  "paymentId": "payment-uuid",
  "amount": 29.99,
  "currency": "EUR",
  "returnUrl": "https://example.com/return",
  "cancelUrl": "https://example.com/cancel"
}
```

Response: `{ "success": true, "orderId": "...", "approvalUrl": "https://..." }`

### Update payment

`POST /gg-homedx-json/gg-api/v1/update-payment`

```json
{
  "paymentId": "payment-uuid",
  "status": "COMPLETED",
  "transactionId": "optional-provider-reference"
}
```

## Webhooks (backend)

Configure in provider dashboards:

| Provider | URL | Secret env |
|----------|-----|------------|
| Stripe | `https://your-host/webhooks/stripe` | `STRIPE_WEBHOOK_SECRET` |
| PayPal | `https://your-host/webhooks/paypal` | (uses PayPal client credentials) |

The Nest app uses `rawBody: true` so Stripe signature verification works.

## Why use SDKs?

### Don't build custom card forms

- PCI scope and liability stay with the processor
- No built-in fraud tools or 3D Secure on DIY forms

### Do use Stripe / PayPal SDKs

- PCI handled by the processor
- 3D Secure / SCA where required
- Standard UX and security updates from vendors

## Testing

- Stripe test cards: https://stripe.com/docs/testing
- PayPal sandbox: https://developer.paypal.com
- Backend e2e: `backend/test/payments-mobile.e2e-spec.ts`

## Resources

- [Stripe Flutter SDK](https://pub.dev/packages/flutter_stripe)
- [PayPal Checkout](https://developer.paypal.com/docs/checkout/)
- [PCI DSS](https://www.pcisecuritystandards.org/)
