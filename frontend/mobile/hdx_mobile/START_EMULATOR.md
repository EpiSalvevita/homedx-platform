# How to Start Your Android Emulator

You have an existing Android Virtual Device called **Medium_Phone_API_36.1**.

## To Start the Emulator:

### Option 1: From Windows Command Prompt or PowerShell
```powershell
cd C:\Users\EpirotAlija\AppData\Local\Android\Sdk\emulator
.\emulator.exe -avd Medium_Phone_API_36.1
```

### Option 2: From Android Studio
1. Open Android Studio
2. Go to **Tools → Device Manager**
3. Find "Medium_Phone_API_36.1" in the list
4. Click the **Play** button (▶️) next to it

### Option 3: Create a Windows shortcut
You can create a desktop shortcut with this command:
```
C:\Users\EpirotAlija\AppData\Local\Android\Sdk\emulator\emulator.exe -avd Medium_Phone_API_36.1
```

## After Starting:

1. Wait for the emulator to fully boot (you'll see the Android home screen)

2. Then in WSL/Cursor, run:
   ```bash
   flutter devices
   ```

3. You should see your Android emulator listed, something like:
   ```
   Android SDK built for x86_64 (mobile) • emulator-5554 • android-x86_64
   ```

4. **Restart Cursor** - After the emulator is running and `flutter devices` shows it, restart Cursor and the Flutter extension should show the device selector in the bottom right corner.

## Troubleshooting:

If `flutter devices` still doesn't show the emulator:
- Make sure the emulator is fully booted (not just starting)
- Check that `ANDROID_HOME` is set correctly in WSL
- Try running: `flutter doctor` to see if there are other issues











