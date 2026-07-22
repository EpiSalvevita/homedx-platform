---
description: Flutter mobile app setup and usage
---

# HomeDX Mobile App (Flutter)

Flutter-based client for the HomeDX platform. The app includes a home screen,
navigation setup, API service layer, and Bluetooth connectivity.

## Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- Android SDK (API 36 or compatible)
- Java JDK 21

## Project Structure

```
hdx_mobile/
├── lib/
│   ├── config/           # App configuration
│   │   ├── app_router.dart    # Navigation routing setup
│   │   └── app_theme.dart     # App theme configuration
│   ├── models/           # Data models
│   ├── providers/        # State management providers
│   │   └── bluetooth_provider.dart  # Bluetooth state management
│   ├── screens/          # Screen widgets
│   │   ├── home_screen.dart              # Home screen
│   │   ├── bluetooth_scan_screen.dart    # BLE device scanning
│   │   ├── bluetooth_connection_screen.dart  # BLE connection management
│   │   └── test_bluetooth_check_screen.dart  # Test with Cube device
│   ├── services/         # Business logic and API services
│   │   ├── api_service.dart       # HTTP REST client (all backend calls)
│   │   ├── auth_service.dart      # Login / register / profile
│   │   ├── payment_service.dart   # Stripe / PayPal via REST
│   │   ├── appointment_service.dart # Bookings and video tokens
│   │   ├── bluetooth_service.dart # BLE (non-Cube)
│   │   └── cube_service.dart      # Cube SDK bridge (MethodChannel/EventChannel)
│   ├── utils/            # Utility functions and constants
│   │   └── constants.dart     # App-wide constants
│   ├── widgets/          # Reusable widget components
│   └── main.dart         # Main application entry point
├── android/              # Android platform-specific code
├── ios/                  # iOS platform-specific code
├── test/                 # Unit and widget tests
├── pubspec.yaml         # Flutter dependencies and configuration
└── README.md            # This file
```

## Getting Started

### 1) Navigate to Project Directory

```bash
cd /home/epi_linux/homedx-platform/frontend/mobile/hdx_mobile
```

### 2) Install Dependencies

```bash
flutter pub get
```

### 2.5) Configure API Base URL

Edit `.env`:
```env
API_BASE_URL=http://10.0.2.2:4000   # Android emulator (Windows host)
API_BASE_URL=http://<windows-lan-ip>:4000   # Physical phone on same Wi-Fi
```

If the backend runs in **WSL2** and the app on a Windows emulator or phone, run
**`scripts/wsl/setup-wsl-port-forward.cmd`** as Administrator from the repo root so Windows
port 4000 reaches WSL (see `docs/WSL2_PORT_FORWARDING.md`).

The main Android manifest enables **cleartext HTTP** for local `API_BASE_URL` (LAN/WSL dev).

If login still shows **connection timeout**, the phone is not reaching Windows on port 4000. On Windows, run `.\scripts\wsl\check-homedx-connectivity.ps1` and ensure `API_BASE_URL` uses the **Windows** IPv4 shown there (not the WSL IP), the backend is running in WSL, and `scripts\wsl\setup-wsl-port-forward.cmd` was run as Administrator after WSL restarts. If the script shows **TCP OK** but **HTTP FAILED**, see **Troubleshooting** in `docs/WSL2_PORT_FORWARDING.md` (WSL mirrored networking or running Nest on Windows).

### 3) Verify Setup

```bash
flutter doctor
```

### 4) Run the App

#### Android Emulator
```bash
flutter devices
flutter run -d emulator-5556
```

#### Physical Android Device
```bash
flutter devices
flutter run
```

#### iOS Simulator (macOS only)
```bash
flutter run
```

## Development

### Hot Reload

- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Building the App

#### Android APK
```bash
flutter build apk --debug
flutter build apk --release
```

#### iOS (macOS only)
```bash
flutter build ios --debug
flutter build ios --release
```

### Flutter Web

The same Flutter app runs in the browser for the public landing page (`/`), patient
features, and the doctor portal (dashboard, availability, video calls).

Edit `.env` for local web development (browser on the same machine as the backend):

```env
API_BASE_URL=http://127.0.0.1:4000
```

Run in Chrome:

```bash
cd frontend/mobile/hdx_mobile
flutter pub get
flutter run -d chrome
```

Build a release bundle:

```bash
flutter build web --release
```

Output is in `build/web/`. Serve locally for smoke testing:

```bash
./serve-web.sh 8080
```

Then open `http://127.0.0.1:8080` (not `localhost` — IPv6 mismatch on WSL2). Hard refresh
after rebuilds. Cube/Bluetooth test flows show a placeholder on web until Web Bluetooth
support is added; use the Android app for Cube E2E.

See also `docs/APPOINTMENTS_VIDEO.md` for doctor web + video call checklist.

## WSL2 Development Setup (Detailed)

See:
- `WSL2_MOBILE_SETUP.md`
- `WSL2_PORT_FORWARDING.md`

## Troubleshooting

### Emulator Not Detected

- Ensure the emulator is fully booted
- Restart ADB: `adb kill-server && adb start-server`
- Check device connection: `flutter devices`

### Build Failures

- `flutter clean`
- `flutter pub get`
- `flutter doctor -v`
- NDK License errors: see `WSL2_MOBILE_SETUP.md`

### Package Manager Service Errors

- Wait for full boot (`adb shell getprop sys.boot_completed`)
- Cold boot emulator
- Consider API 34/35 instead of 36

## Features

### Implemented

- Authentication & user management (REST + GoRouter guards)
- Appointments & video calls (patient mobile + doctor web)
- Shop / checkout with Stripe and PayPal (`PaymentService`)
- Test selection and Cube measurement flow
- Bluetooth connectivity (scan/connect)
- Navigation with GoRouter (no `Navigator.push` in app code)
- Cube device integration via native Android SDK
- Cube data submission to backend (`POST submit-cube-data`)

### Cube Device Integration

The app uses the native Cube Android SDK (cubelib AAR) via a Kotlin bridge.
Scanning is filtered to Cube devices only; no Windows service is used.

**Bluetooth pairing (Android):** When the phone asks for a PIN or passkey to pair the Cube, use the **last six digits of the Cube’s serial number** (numeric characters only, in order as they appear on the device label).

**Paired in Settings vs connected in the app:** Pairing the Cube under Android **Settings → Bluetooth** only registers the device with the OS. The homeDX app still uses the **Cube native SDK** scan list: open the in-app **Cube-Gerät suchen** flow, grant **Nearby devices / Bluetooth scan & connect** (and **Location** when prompted), wait until your Cube appears, then tap **Verbinden**. Until the SDK reaches **`ST_IDLE`**, the test flow treats the Cube as disconnected.

**If the scan list stays empty:** Keep the Cube **on**, **charged**, and **paired** in Android settings (PIN = last six digits of the serial number). The Chembio SDK only lists devices it can discover over BLE; wait the full scan (~30s). The app now **disconnects the native Cube transport before each scan** so a stale half-open link cannot block discovery (`startScan` is skipped while `isConnectionOpen()` is true, which is a different flag than “connected” in the UI).

**Key Components:**
- `CubeService` (`lib/features/cube/cube_service.dart`) – Flutter bridge to native Cube SDK
- `CubeBridge` (`android/.../CubeAnalysisMethodChannel.kt`) – Kotlin MethodChannel/EventChannel wrapper
- `cubelib-release.aar` + `cube_license.dat` – Cube SDK and license in `android/app/libs` and `assets`

**Test Flow:**
1. User selects a test type and taps "Nach Cube-Geräten suchen"
2. Cube SDK scans for Cube devices only (filtered)
3. User connects to a Cube device
4. User taps "Test starten"; Cube SDK runs evaluation on-device
5. App reads measurement results from Cube SDK
6. App sends result data to backend (`POST submit-cube-data`)
7. Backend stores/normalizes and returns results to app

## Testing

```bash
flutter test
```

## Platform Support

- Android, iOS, Web, Linux, macOS, Windows

## Version

Current version: `1.1.1+3`
