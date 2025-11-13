# Setting Up Android Devices in Flutter (WSL2)

## Current Situation
- ✅ Android SDK is installed on Windows
- ✅ Android emulator (Medium_Phone_API_36.1) is configured
- ❌ No Android devices currently detected by Flutter

## Why Android Devices Don't Show Up

The Android emulator needs to be **running on Windows** before Flutter in WSL can detect it. Flutter can't start emulators directly from WSL, but it can detect them once they're running.

## Step-by-Step: Getting Android Devices to Appear

### Step 1: Start Your Android Emulator on Windows

You have **3 options** to start the emulator:

#### Option A: From Windows Command Prompt/PowerShell (Easiest)
1. Open **Command Prompt** or **PowerShell** on Windows (NOT in WSL)
2. Run:
   ```powershell
   cd C:\Users\EpirotAlija\AppData\Local\Android\Sdk\emulator
   .\emulator.exe -avd Medium_Phone_API_36.1
   ```

#### Option B: From Android Studio
1. Open **Android Studio** on Windows
2. Go to **Tools → Device Manager**
3. Find **"Medium_Phone_API_36.1"**
4. Click the **Play** button (▶️) next to it

#### Option C: Create a Windows Shortcut
Create a shortcut with this target:
```
C:\Users\EpirotAlija\AppData\Local\Android\Sdk\emulator\emulator.exe -avd Medium_Phone_API_36.1
```

### Step 2: Wait for Emulator to Boot
- Wait for the emulator window to appear
- Wait for the Android home screen to load
- This can take 30-60 seconds

### Step 3: Verify in WSL
Once the emulator is running, in your WSL terminal (or Cursor):

```bash
# Check if ADB can see it
/mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/platform-tools/adb.exe devices

# Check if Flutter can see it
flutter devices
```

You should see something like:
```
Found 2 connected devices:
  Linux (desktop)        • linux • linux-x64
  sdk gphone64 (mobile)  • emulator-5554 • android-x86_64
```

### Step 4: Refresh in Cursor
1. **Restart Cursor** (close and reopen)
2. OR press `Ctrl+Shift+P` → `Developer: Reload Window`
3. The device selector in the bottom-right should now show Android devices

## Quick Test Script

You can use the provided script to start the emulator from WSL:
```bash
./start-android-emulator.sh
```

This will attempt to start the emulator, but you may need to start it manually from Windows if WSL can't execute Windows executables directly.

## Troubleshooting

### If `flutter devices` doesn't show the Android emulator:

1. **Check ADB connection:**
   ```bash
   /mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/platform-tools/adb.exe devices
   ```
   - If empty: Emulator isn't fully booted or ADB can't connect
   - If you see `emulator-5554`: Device is connected but Flutter might not see it

2. **Restart ADB server:**
   ```bash
   /mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/platform-tools/adb.exe kill-server
   /mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/platform-tools/adb.exe start-server
   flutter devices
   ```

3. **Check Android SDK path:**
   ```bash
   flutter config --android-sdk /mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk
   ```

4. **Verify emulator is fully booted:**
   - The emulator window should show the Android home screen
   - Not just the boot animation

### If ADB shows "unauthorized":
- Check the emulator screen - you might see a "Allow USB debugging?" prompt
- Click "Allow" or "Always allow"

## Using Physical Android Device

If you want to use a physical Android phone:

1. **Enable Developer Options:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times

2. **Enable USB Debugging:**
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect via USB:**
   - Connect your phone to Windows
   - When prompted, allow USB debugging

4. **Verify in WSL:**
   ```bash
   /mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/platform-tools/adb.exe devices
   flutter devices
   ```

## Summary

**The key steps:**
1. ✅ Start emulator on **Windows** (not WSL)
2. ✅ Wait for it to fully boot
3. ✅ Verify with `flutter devices` in WSL
4. ✅ Restart Cursor to refresh device list

Once the emulator is running, you should see it in:
- `flutter devices` command
- Cursor's device selector (bottom-right)
- Run and Debug panel











