# Payment Integration Guide

## Overview

This app uses **proper payment SDKs** for secure, PCI-compliant payment processing. **Never collect or store raw credit card data** - always use payment processors.

## Payment Methods

### 1. Credit Card (Stripe)

**Package**: `flutter_stripe: ^11.1.0`

**How it works:**
1. Backend creates a Stripe Payment Intent and returns a `client_secret`
2. Flutter app uses Stripe SDK to collect card details (handled securely by Stripe)
3. Stripe SDK tokenizes the card and processes payment
4. Payment is confirmed via Stripe API
5. Backend updates payment status to COMPLETED

**Security**: 
- ✅ PCI DSS compliant (Stripe handles all card data)
- ✅ Card details never touch your servers
- ✅ Supports 3D Secure (SCA compliance)

**Setup Required:**
1. Get Stripe API keys from https://stripe.com
2. Add to backend `.env`:
   ```
   STRIPE_SECRET_KEY=sk_test_...
   STRIPE_PUBLISHABLE_KEY=pk_test_...
   ```
3. Add to Flutter `.env`:
   ```
   STRIPE_PUBLISHABLE_KEY=pk_test_...
   ```
4. Initialize Stripe in `main.dart`:
   ```dart
   Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
   ```

### 2. PayPal

**Package**: `webview_flutter: ^4.9.0`

**How it works:**
1. Backend creates a PayPal order via PayPal API
2. Flutter app opens PayPal Checkout in WebView
3. User completes payment on PayPal's secure site
4. PayPal redirects back with approval token
5. Backend captures payment and updates status

**Security**:
- ✅ PayPal handles all payment processing
- ✅ OAuth 2.0 authentication
- ✅ Secure redirect flow

**Setup Required:**
1. Create PayPal app at https://developer.paypal.com
2. Add to backend `.env`:
   ```
   PAYPAL_CLIENT_ID=...
   PAYPAL_CLIENT_SECRET=...
   PAYPAL_MODE=sandbox  # or 'live'
   ```

### 3. SEPA Bank Transfer

**Custom Implementation** (no SDK needed)

**How it works:**
1. User confirms bank transfer details
2. Payment record created with status PENDING
3. User transfers money manually to provided IBAN
4. Admin manually verifies and updates status to COMPLETED

**Security**:
- ✅ No sensitive data collected
- ✅ Manual verification process

## Backend Integration

### Required Backend Endpoints

1. **Create Payment Intent** (for Stripe)
   ```graphql
   mutation CreatePaymentIntent {
     createPaymentIntent {
       success
       secret  # Stripe client secret
     }
   }
   ```

2. **Create PayPal Order** (for PayPal)
   ```graphql
   mutation CreatePayPalOrder($amount: Float!, $currency: String!) {
     createPayPalOrder(amount: $amount, currency: $currency) {
       orderId
       approvalUrl
     }
   }
   ```

3. **Update Payment Status**
   ```graphql
   mutation UpdatePayment($id: String!, $input: UpdatePaymentInput!) {
     updatePayment(id: $id, input: $input) {
       id
       status
       transactionId
     }
   }
   ```

## Why Use SDKs?

### ❌ **DON'T** Build Custom Payment Forms
- Requires PCI DSS Level 1 compliance (expensive, complex)
- Security vulnerabilities (card data exposure)
- Legal liability for data breaches
- No fraud protection
- No 3D Secure support

### ✅ **DO** Use Payment SDKs
- PCI compliance handled by processor
- Built-in fraud protection
- 3D Secure / SCA support
- Better user experience
- Industry-standard security

## Next Steps

1. **Backend**: Implement Stripe and PayPal integrations
   - Install `stripe` npm package
   - Install `@paypal/checkout-server-sdk` npm package
   - Create payment intent resolver
   - Create PayPal order resolver

2. **Flutter**: Configure Stripe publishable key
   - Add to `.env` file
   - Initialize in `main.dart`

3. **Testing**: Use test credentials
   - Stripe test cards: https://stripe.com/docs/testing
   - PayPal sandbox: https://developer.paypal.com

## Resources

- [Stripe Flutter SDK](https://pub.dev/packages/flutter_stripe)
- [Stripe Documentation](https://stripe.com/docs)
- [PayPal Checkout SDK](https://developer.paypal.com/docs/checkout/)
- [PCI DSS Compliance](https://www.pcisecuritystandards.org/)




