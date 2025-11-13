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

### 1. Navigate to Project Directory

```bash
cd /home/epi_linux/homedx-platform/mobile/hdx_mobile
```

**Note**: If you're using WSL2, complete the [WSL2 Development Setup](#wsl2-development-setup) section first.

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

1. **Start the emulator** (see [WSL2 Development Setup](#wsl2-development-setup) if using WSL2):
   - From Android Studio: Tools → Device Manager → Click Play button
   - Or from command line: See Step 4 in WSL2 setup section

2. **Verify the emulator is detected**:
   ```bash
   flutter devices
   ```

3. **Run the app**:
   ```bash
   flutter run -d emulator-5556
   ```
   (Replace `emulator-5556` with your emulator's device ID from `flutter devices` output)

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

## WSL2 Development Setup

If you're developing in WSL2 (Windows Subsystem for Linux), follow these steps to set up Android emulator connectivity:

### Prerequisites

1. **Install Linux build tools** (required for Flutter development):
   ```bash
   sudo apt update
   sudo apt install -y clang cmake ninja-build pkg-config
   ```

2. **Verify Android SDK location on Windows**:
   - Default location: `C:\Users\<YourUsername>\AppData\Local\Android\Sdk`
   - Replace `<YourUsername>` with your Windows username

### Step 1: Configure ADB to Connect to Windows ADB Server

Add the following to your `~/.bashrc` to connect ADB to the Windows ADB server:

```bash
# Android ADB configuration for WSL2 - Connect to Windows ADB server
export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037
```

Reload your shell configuration:
```bash
source ~/.bashrc
```

### Step 2: Create ADB Wrapper for Flutter

Flutter needs an ADB executable (not `.exe`), so create a wrapper:

```bash
# Create wrapper directory
mkdir -p ~/android-sdk-wrapper/platform-tools

# Create ADB wrapper script
cat > ~/android-sdk-wrapper/platform-tools/adb << 'EOF'
#!/bin/bash
export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037
exec /mnt/c/Users/<YourUsername>/AppData/Local/Android/Sdk/platform-tools/adb.exe "$@"
EOF

# Make it executable
chmod +x ~/android-sdk-wrapper/platform-tools/adb
```

**Important**: Replace `<YourUsername>` with your actual Windows username (e.g., `epiro`).

### Step 2.5: Copy Android SDK Licenses

Copy the license files from your Windows Android SDK to the wrapper so Gradle can accept them:

```bash
# Copy all license files
mkdir -p ~/android-sdk-wrapper/licenses
cp -r /mnt/c/Users/<YourUsername>/AppData/Local/Android/Sdk/licenses/* ~/android-sdk-wrapper/licenses/
```

This prevents `LicenceNotAcceptedException` errors during builds, especially for NDK components.

### Step 3: Configure Flutter to Use the ADB Wrapper

```bash
flutter config --android-sdk ~/android-sdk-wrapper
```

### Step 4: Start Android Emulator on Windows

The emulator must be started on Windows (not from WSL2). You have several options:

**Option A: From Windows Command Prompt/PowerShell**
```powershell
cd C:\Users\<YourUsername>\AppData\Local\Android\Sdk\emulator
.\emulator.exe -avd <YourAVDName>
```

**Option B: From Android Studio**
1. Open Android Studio on Windows
2. Go to **Tools → Device Manager**
3. Find your AVD and click the **Play** button (▶️)

**Option C: List available AVDs first**
```bash
cmd.exe /c "C:\Users\<YourUsername>\AppData\Local\Android\Sdk\emulator\emulator.exe -list-avds"
```

### Step 5: Verify Connection

Once the emulator is running and fully booted (wait for the Android home screen):

```bash
# Check ADB can see the device
~/android-sdk-wrapper/platform-tools/adb devices

# Check Flutter can detect the device
flutter devices
```

You should see output like:
```
Found 2 connected devices:
  sdk gphone64 x86 64 (mobile) • emulator-5556 • android-x64 • Android 15 (API 35) (emulator)
  Linux (desktop)              • linux         • linux-x64   • Ubuntu 24.04.2 LTS ...
```

### Step 6: Set Up Port Forwarding for Backend Connectivity

**IMPORTANT**: If you're running the backend in WSL2 and the Flutter app on an Android emulator in Windows, you need to set up port forwarding so the emulator can reach the WSL2 backend.

#### The Problem

- The backend runs in WSL2 on port 4000
- The Android emulator runs on Windows
- The emulator uses `10.0.2.2` to access Windows localhost
- Windows localhost doesn't automatically forward to WSL2
- **Result**: Connection timeouts when the app tries to reach the backend

#### The Solution

Set up port forwarding from Windows localhost:4000 to WSL2:4000.

**Quick Setup** (run in Windows PowerShell as Administrator):

1. Get your WSL2 IP address:
   ```powershell
   wsl hostname -I
   ```
   This will output something like `172.26.71.195`

2. Set up port forwarding:
   ```powershell
   netsh interface portproxy add v4tov4 listenport=4000 listenaddress=127.0.0.1 connectport=4000 connectaddress=172.26.71.195
   ```
   Replace `172.26.71.195` with your actual WSL2 IP from step 1.

3. Verify it worked:
   ```powershell
   netsh interface portproxy show all
   ```
   You should see the forwarding rule listed.

**Alternative: Use the Setup Script**

A PowerShell script is available at the project root (`setup-wsl-port-forward.ps1`) that automates this process. Run it from Windows PowerShell as Administrator:

```powershell
.\setup-wsl-port-forward.ps1
```

**Important Notes**:
- You must run PowerShell **as Administrator** for port forwarding to work
- If you restart WSL2, the IP address may change. You'll need to run the setup again
- To remove port forwarding: `netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=127.0.0.1`
- The backend must be configured to listen on `0.0.0.0` (check `backend/src/main.ts` - it should have `app.listen(4000, '0.0.0.0')`)

**Verify Backend is Accessible**:

From Windows PowerShell (not as admin is fine for testing):
```powershell
curl http://localhost:4000/gg-homedx-json/gg-api/v1/get-be-status-flags -X POST -H "Content-Type: application/json" -d "{}"
```

You should see: `{"success":true,"cwa":true,"cwaLaive":true}`

### Troubleshooting WSL2 Setup

- **Emulator shows as "offline"**: Wait for the emulator to fully boot (Android home screen visible)
- **Flutter can't find ADB**: Verify the wrapper path and that `flutter config --android-sdk` points to `~/android-sdk-wrapper`
- **Connection refused errors**: Ensure the Windows ADB server is running and the `ADB_SERVER_SOCKET` is set correctly
- **File Watcher warnings**: These are WSL2 file system issues and don't affect Flutter CLI builds
- **NDK License Error**: If you see `LicenceNotAcceptedException` for NDK during build:
  ```bash
  # Copy licenses from Windows SDK to wrapper
  mkdir -p ~/android-sdk-wrapper/licenses
  cp -r /mnt/c/Users/<YourUsername>/AppData/Local/Android/Sdk/licenses/* ~/android-sdk-wrapper/licenses/
  ```
  Replace `<YourUsername>` with your Windows username. This ensures the wrapper SDK has all required license agreements.
- **Connection Timeout / Backend Not Reachable**: 
  - Ensure port forwarding is set up (see Step 6 above)
  - Verify the backend is running: `curl http://localhost:4000/...` from WSL2
  - Check Flutter app's `.env` file has `API_BASE_URL=http://10.0.2.2:4000`
  - If WSL2 IP changed after restart, update port forwarding with the new IP

## Troubleshooting

### Emulator Not Detected

- Ensure the emulator is fully booted (wait for the home screen)
- Restart ADB: `adb kill-server && adb start-server`
- Check device connection: `flutter devices`

### Build Failures

- Clean the build: `flutter clean`
- Get dependencies again: `flutter pub get`
- Check Flutter doctor: `flutter doctor -v`
- **NDK License Error**: If build fails with `LicenceNotAcceptedException`, ensure licenses are copied (see Step 2.5 in WSL2 Setup)

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
