# Fix: Android Emulator Detection in WSL2

## Current Issue
- ✅ Emulator is running on Windows
- ✅ Windows ADB can see the device (`adb.exe devices` shows `emulator-5554`)
- ❌ Flutter in WSL2 cannot detect the Android device

## Root Cause
Flutter in WSL2 needs to use the Windows ADB server, but there's a connectivity issue between WSL2 and Windows for ADB.

## Solution Options

### Option 1: Use Windows ADB Directly (Recommended)

Create an alias or wrapper to use Windows ADB:

1. **Add to your `~/.bashrc` or `~/.zshrc`:**
   ```bash
   # Use Windows ADB for Flutter
   alias adb='/mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/platform-tools/adb.exe'
   ```

2. **Reload your shell:**
   ```bash
   source ~/.bashrc
   ```

3. **Test:**
   ```bash
   adb devices
   flutter devices
   ```

### Option 2: Port Forwarding (Alternative)

If Option 1 doesn't work, try setting up port forwarding:

1. **On Windows (PowerShell as Administrator):**
   ```powershell
   netsh interface portproxy add v4tov4 listenport=5037 listenaddress=0.0.0.0 connectport=5037 connectaddress=127.0.0.1
   ```

2. **In WSL2, set ADB to use Windows host:**
   ```bash
   export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037
   ```

3. **Test:**
   ```bash
   adb devices
   flutter devices
   ```

### Option 3: Install ADB in WSL and Connect to Windows Server

1. **Stop local ADB server:**
   ```bash
   adb kill-server
   ```

2. **Find Windows host IP:**
   ```bash
   cat /etc/resolv.conf | grep nameserver | awk '{print $2}'
   ```

3. **Connect to Windows ADB:**
   ```bash
   export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037
   adb devices
   ```

### Option 4: Run Flutter from Windows (Workaround)

If all else fails, you can run Flutter commands from Windows PowerShell:
1. Open PowerShell on Windows
2. Navigate to your project
3. Run `flutter devices` and `flutter run` from there
4. Use Cursor on Windows, or use Remote-WSL to connect from Windows Cursor to WSL

## Quick Test

After trying any solution above, test with:
```bash
# Should show emulator-5554
adb devices

# Should show both Linux and Android device
flutter devices
```

## Persistence

To make the ADB configuration permanent, add to your `~/.bashrc`:
```bash
# Android ADB configuration for WSL2
export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037
# Or use Windows ADB directly:
alias adb='/mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/platform-tools/adb.exe'
```

## Notes

- The emulator must be running on Windows before Flutter can detect it
- You may need to restart Cursor after making these changes
- The `cmdline-tools` missing warning is separate and won't prevent device detection, but you should install it for full Android support











