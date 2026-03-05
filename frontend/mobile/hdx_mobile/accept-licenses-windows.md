# Accept Android SDK Licenses on Windows

The NDK license needs to be accepted. Since we're in WSL2, we need to do this on Windows.

## Option 1: Accept Licenses via Android Studio (Easiest)

1. Open **Android Studio** on Windows
2. Go to **Tools → SDK Manager**
3. Click **"SDK Tools"** tab
4. Make sure **"NDK (Side by side)"** version 27.0.12077973 is checked
5. Click **"Apply"** - it will prompt you to accept licenses
6. Accept all licenses

## Option 2: Accept Licenses via Command Line (Windows)

1. Open **Command Prompt** or **PowerShell** on Windows (NOT WSL)
2. Run:
   ```powershell
   cd C:\Users\EpirotAlija\AppData\Local\Android\Sdk\cmdline-tools\latest\bin
   .\sdkmanager.bat --licenses
   ```
3. Type `y` and press Enter for each license prompt
4. Accept all licenses

## Option 3: Copy Licenses from Windows (If Already Accepted)

If you've already accepted licenses in Android Studio, copy them:

From WSL terminal, run:
```bash
cp -r /mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/licenses/* ~/android-sdk-wrapper/licenses/
```

Then try building again:
```bash
flutter run -d emulator-5554
```

## After Accepting Licenses

Once licenses are accepted on Windows, copy them to the wrapper:
```bash
cp -r /mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/licenses/* ~/android-sdk-wrapper/licenses/
```

Then try running your app again!










