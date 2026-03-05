# HomeDX App Functionality Matrix

Short, current snapshot of what exists in backend vs app. This is not a backlog.

## Authentication & User Management

- **Backend ready:** login, register, get/update user data
- **App implemented:** login, signup, profile view/edit

## Rapid Test Flow

- **Backend ready:** test type list, add test, get last test, media upload endpoints
- **App implemented:** test selection screens, basic flow

## Certificates

- **Backend ready:** certificate creation, PDF, QR, list/query endpoints
- **App implemented:** not fully wired in current Flutter app

## Payments

- **Backend ready:** Stripe + PayPal integrations, payment intent + history
- **App implemented:** not fully wired in current Flutter app

## Licenses & Coupons

- **Backend ready:** activate license, assign coupon, user license queries
- **App implemented:** not fully wired in current Flutter app

## Test Kits

- **Backend ready:** test kit CRUD + assignment
- **App implemented:** not fully wired in current Flutter app

## Notifications

- **Backend ready:** notification storage + read state
- **App implemented:** basic UI, push not wired

## File Uploads

- **Backend ready:** photo/video/ID upload endpoints
- **App implemented:** partial (screens exist, wiring pending)

## System & Legal

- **Backend ready:** status flags, legal content endpoints
- **App implemented:** basic settings/legal screens

## Bluetooth & Cube Device

- **App implemented:** Cube-only BLE scan, connect, run measurement, submit results
- **Backend ready:** `submit-cube-data` endpoint for storing Cube results from mobile
- **Android flow:** Native Cube SDK (cubelib AAR) processes measurements on-device; no Windows service

**Cube Test Flow:**
1. App scans for Cube devices only (Cube SDK filter)
2. User connects to Cube device
3. User starts test; Cube SDK runs evaluation on-device
4. App reads measurement results from Cube SDK
5. App sends result payload to backend (`POST /submit-cube-data`)
6. Backend stores/normalizes and returns results to app

## Notes

- Mobile API base path: `/gg-homedx-json/gg-api/v1/*`
- Auth: Bearer token or `x-auth-token`

