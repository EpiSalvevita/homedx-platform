# Payment Integration Guide

Payments use the **mobile REST API** and payment-provider SDKs on the client. Card data never touches your servers.

**Flutter client:** `lib/services/payment_service.dart`  
**Backend:** `MobilePaymentService` + `mobile-payment.controller.ts`  
**Webhooks:** `POST /webhooks/stripe`, `POST /webhooks/paypal`

All mobile payment routes require JWT auth (`Authorization: Bearer …` or `x-auth-token`).

Base path: `/gg-homedx-json/gg-api/v1`

## Security model

- **Server computes charge amount** — clients cannot set arbitrary prices.
- **Only the server marks payments `COMPLETED`** — via Stripe webhook / `confirm-stripe-payment`, or PayPal `capture-paypal-order` / verified webhook.
- **`update-payment` does not accept `status`** — only links provider IDs before capture.

## Payment methods

### 1. Credit card (Stripe)

**Package:** `flutter_stripe` (PaymentSheet — no custom PAN fields)

**Flow:**

1. App calls `POST create-payment` → payment record (`PENDING`, server amount)
2. App calls `POST create-stripe-payment-intent` with `paymentId` → `clientSecret`
3. Stripe PaymentSheet confirms on device
4. App calls `POST confirm-stripe-payment` with `paymentId` (or polls `get-payment` until webhook completes)

**Setup:**

Backend `backend/.env`:

```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

Flutter `frontend/mobile/hdx_mobile/.env` (bundled asset — **publishable key only**):

```env
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### 2. PayPal

**Package:** `webview_flutter` (navigation restricted to PayPal hosts)

**Flow:**

1. App calls `POST create-payment`
2. App calls `POST create-paypal-order` with `paymentId`, optional `returnUrl` / `cancelUrl`
3. User completes checkout in PayPal WebView
4. App calls `POST capture-paypal-order` with `paymentId` (server captures funds)
5. PayPal webhook (`CHECKOUT.ORDER.APPROVED`) can also complete after signature verification

**Setup:**

```env
PAYPAL_CLIENT_ID=...
PAYPAL_CLIENT_SECRET=...
PAYPAL_WEBHOOK_ID=...
PAYPAL_MODE=sandbox
```

### 3. SEPA bank transfer

Manual flow: payment stays `PENDING` until admin confirms bank receipt.

## REST endpoints

### Get payment amount

`POST /gg-homedx-json/gg-api/v1/get-payment-amount`

### Create payment

`POST /gg-homedx-json/gg-api/v1/create-payment`

```json
{
  "paymentMethod": "CREDIT_CARD",
  "rapidTestId": "optional-rapid-test-id"
}
```

Amount and currency are set server-side.

### Get payment status

`POST /gg-homedx-json/gg-api/v1/get-payment`

```json
{ "paymentId": "payment-uuid" }
```

### Create Stripe PaymentIntent

`POST /gg-homedx-json/gg-api/v1/create-stripe-payment-intent`

```json
{ "paymentId": "payment-uuid" }
```

### Confirm Stripe payment (server checks PaymentIntent)

`POST /gg-homedx-json/gg-api/v1/confirm-stripe-payment`

```json
{ "paymentId": "payment-uuid" }
```

### Create PayPal order

`POST /gg-homedx-json/gg-api/v1/create-paypal-order`

```json
{
  "paymentId": "payment-uuid",
  "returnUrl": "https://example.com/paypal/return",
  "cancelUrl": "https://example.com/paypal/cancel"
}
```

### Capture PayPal order (server-side)

`POST /gg-homedx-json/gg-api/v1/capture-paypal-order`

```json
{
  "paymentId": "payment-uuid",
  "paypalOrderId": "optional-if-not-stored"
}
```

### Update payment (metadata only)

`POST /gg-homedx-json/gg-api/v1/update-payment`

```json
{
  "paymentId": "payment-uuid",
  "paymentIntentId": "optional",
  "paypalOrderId": "optional"
}
```

## Webhooks (backend)

| Provider | URL | Verification |
|----------|-----|--------------|
| Stripe | `https://your-host/webhooks/stripe` | `STRIPE_WEBHOOK_SECRET` |
| PayPal | `https://your-host/webhooks/paypal` | `PAYPAL_WEBHOOK_ID` + transmission headers |

The Nest app uses `rawBody: true` for Stripe signature verification.

## Testing

- Stripe test cards: https://stripe.com/docs/testing
- PayPal sandbox: https://developer.paypal.com
- Backend e2e: `backend/test/payments-mobile.e2e-spec.ts`

## Resources

- [Stripe Flutter SDK](https://pub.dev/packages/flutter_stripe)
- [PayPal Checkout](https://developer.paypal.com/docs/checkout/)
