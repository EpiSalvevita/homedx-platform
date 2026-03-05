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
│   │   ├── api_service.dart       # HTTP client wrapper
│   │   ├── bluetooth_service.dart # BLE (BluetoothProvider, non-Cube)
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

- Authentication & user management
- Test selection screens
- Bluetooth connectivity (scan/connect/read/write)
- Navigation with guards
- Cube device integration via Bluetooth
- Cube data submission to backend for result storage

### Cube Device Integration

The app uses the native Cube Android SDK (cubelib AAR) via a Kotlin bridge.
Scanning is filtered to Cube devices only; no Windows service is used.

**Key Components:**
- `CubeService` (`lib/services/cube_service.dart`) – Flutter bridge to native Cube SDK
- `CubeBridge` (`android/.../CubeAnalysisMethodChannel.kt`) – Kotlin MethodChannel/EventChannel wrapper
- `cubelib-release.aar` + `cube_license.dat` – Cube SDK and license in `android/app/libs` and `assets`

**Test Flow:**
1. User selects a test type and taps "Nach Cube-Geräten suchen"
2. Cube SDK scans for Cube devices only (filtered)
3. User connects to a Cube device
4. User taps "Test starten"; Cube SDK runs evaluation on-device
5. App reads measurement results from Cube SDK
6. App sends result data to backend (`POST /submit-cube-data`)
7. Backend stores/normalizes and returns results to app

## Testing

```bash
flutter test
```

## Platform Support

- Android, iOS, Web, Linux, macOS, Windows

## Version

Current version: `1.0.0+1`
