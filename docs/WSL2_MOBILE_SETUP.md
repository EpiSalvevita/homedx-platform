---
description: WSL2 setup for Flutter mobile development
---

# WSL2 Mobile Development Setup (Flutter)

Use this when developing the Flutter app from WSL2 and targeting Android devices/emulators running on Windows.

## Prerequisites

1) Install Linux build tools:
```bash
sudo apt update
sudo apt install -y clang cmake ninja-build pkg-config
```

2) Verify Android SDK location on Windows:
- Default location: `C:\Users\<YourUsername>\AppData\Local\Android\Sdk`

## Step 1: Configure ADB to Connect to Windows ADB Server

Add the following to your `~/.bashrc`:
```bash
export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037
```

Reload your shell:
```bash
source ~/.bashrc
```

## Step 2: Create ADB Wrapper for Flutter

Flutter needs a non-`.exe` adb executable:
```bash
mkdir -p ~/android-sdk-wrapper/platform-tools

cat > ~/android-sdk-wrapper/platform-tools/adb << 'EOF'
#!/bin/bash
export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037
exec /mnt/c/Users/<YourUsername>/AppData/Local/Android/Sdk/platform-tools/adb.exe "$@"
EOF

chmod +x ~/android-sdk-wrapper/platform-tools/adb
```

Replace `<YourUsername>` with your Windows username.

## Step 2.5: Copy Android SDK Licenses

```bash
mkdir -p ~/android-sdk-wrapper/licenses
cp -r /mnt/c/Users/<YourUsername>/AppData/Local/Android/Sdk/licenses/* ~/android-sdk-wrapper/licenses/
```

## Step 3: Configure Flutter to Use the ADB Wrapper

```bash
flutter config --android-sdk ~/android-sdk-wrapper
```

## Step 4: Start Android Emulator on Windows

Start from Windows (not WSL2):

- Android Studio: Tools → Device Manager → Play
- Or command line:
```powershell
cd C:\Users\<YourUsername>\AppData\Local\Android\Sdk\emulator
.\emulator.exe -avd <YourAVDName>
```

## Step 5: Verify Connection

```bash
~/android-sdk-wrapper/platform-tools/adb devices
flutter devices
```

## Step 6: Port Forwarding for Backend Connectivity

If backend runs in WSL2 and the app runs on Windows/phone, follow:

- `docs/WSL2_PORT_FORWARDING.md`

## Troubleshooting (Common)

- Emulator shows as "offline": wait for full boot
- Flutter can't find ADB: recheck wrapper path and `flutter config`
- NDK License errors: copy licenses (Step 2.5)
- Connection timeout: verify port forwarding + `.env` `API_BASE_URL`
