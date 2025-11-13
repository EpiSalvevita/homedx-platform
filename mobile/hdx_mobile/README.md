# hdx_mobile

HomeDX Platform Mobile Application - A Flutter-based mobile app for the HomeDX platform.

## Overview

This is the mobile application component of the HomeDX platform, built with Flutter. The app includes a modern home screen with quick actions, navigation setup, API service layer, and is ready for feature development.

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
│   ├── screens/          # Screen widgets
│   │   └── home_screen.dart   # Home screen
│   ├── services/         # Business logic and API services
│   │   └── api_service.dart   # HTTP client wrapper
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

### 1. Clone the Repository

```bash
cd /home/epilinux3/homedx-platform/mobile/hdx_mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

Check that Flutter is properly configured:

```bash
flutter doctor
```

### 4. Run the App

#### On Android Emulator

1. Start an Android emulator from Android Studio (AVD Manager)
2. Verify the emulator is detected:
   ```bash
   flutter devices
   ```
3. Run the app:
   ```bash
   flutter run -d emulator-5554
   ```
   (Replace `emulator-5554` with your emulator's device ID if different)

#### On Physical Android Device

1. Enable USB debugging on your Android device
2. Connect the device via USB
3. Verify the device is detected:
   ```bash
   flutter devices
   ```
4. Run the app:
   ```bash
   flutter run
   ```

#### On iOS Simulator (macOS only)

1. Open iOS Simulator from Xcode
2. Run the app:
   ```bash
   flutter run
   ```

## Development

### Hot Reload

While the app is running, you can use hot reload to see changes instantly:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Building the App

#### Android APK

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

#### iOS (macOS only)

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## WSL2 Development Notes

If you're developing in WSL2 (Windows Subsystem for Linux):

1. **Android SDK Setup**: The project uses an Android SDK wrapper located at `/home/epilinux3/android-sdk-wrapper`
2. **ADB Connection**: ADB may need to connect through Windows paths. The project is configured to work with both WSL and Windows ADB.
3. **File Watcher**: If you see "File watcher failed" warnings in Android Studio, this is typically a WSL2 file system issue and doesn't affect Flutter CLI builds.

## Troubleshooting

### Emulator Not Detected

- Ensure the emulator is fully booted (wait for the home screen)
- Restart ADB: `adb kill-server && adb start-server`
- Check device connection: `flutter devices`

### Build Failures

- Clean the build: `flutter clean`
- Get dependencies again: `flutter pub get`
- Check Flutter doctor: `flutter doctor -v`

### Package Manager Service Errors

If you encounter "Can't find service: package" errors:
- Wait for the emulator to fully boot (check with `adb shell getprop sys.boot_completed`)
- Try a cold boot of the emulator (wipe data)
- Consider using an emulator with API 34 or 35 instead of API 36

## Dependencies

Current dependencies (see `pubspec.yaml` for details):
- `flutter` - Flutter SDK
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `provider: ^6.1.2` - State management
- `go_router: ^14.2.7` - Navigation and routing
- `http: ^1.2.2` - HTTP client for API calls
- `flutter_dotenv: ^5.1.0` - Environment configuration
- `shared_preferences: ^2.2.3` - Local storage

## Testing

Run tests with:

```bash
flutter test
```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS
- ✅ Windows

## Version

Current version: `1.0.0+1`

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter API Reference](https://api.flutter.dev/)

## License

This project is part of the HomeDX platform.
