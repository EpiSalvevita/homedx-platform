# Dart DevTools Button Not Appearing - Troubleshooting Guide

## Important: The Button Only Appears During Debug Sessions

The **Dart DevTools** button in the status bar at the bottom of Cursor/VS Code only appears **when your Flutter app is running in debug mode**. It won't show up just by opening the project.

## How to See the Dart DevTools Button:

### Step 1: Make sure you have a device/emulator available
```bash
flutter devices
```
You should see at least one device listed (emulator or physical device).

### Step 2: Start your app in debug mode

**Option A: Using the Debug Panel**
1. Click on the **Run and Debug** icon in the left sidebar (or press `Ctrl+Shift+D`)
2. Select "hdx_mobile" from the dropdown at the top
3. Press `F5` or click the green play button

**Option B: Using the Command Palette**
1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Flutter: Launch Emulator" (if you need to start an emulator first)
3. Then type "Flutter: Run Flutter" or press `F5`

**Option C: Using the status bar**
- Look for the device selector in the bottom right (e.g., "No Device")
- Click it to select a device
- Then press `F5` to run

### Step 3: Check the status bar

Once your app is running in debug mode, you should see in the bottom status bar:
- **Device name** (e.g., "Chrome", "Linux", or your Android emulator)
- **Dart DevTools** button (looks like a small icon, usually near the device selector)
- **Debug toolbar** (with play/pause/stop buttons)

## If the Button Still Doesn't Appear:

### 1. Verify Extensions Are Installed
- Open Extensions (`Ctrl+Shift+X`)
- Search for "Dart" - make sure it's installed and enabled
- Search for "Flutter" - make sure it's installed and enabled
- Reload Cursor after installing

### 2. Reload the Window
- Press `Ctrl+Shift+P`
- Type "Developer: Reload Window"
- Select it to reload Cursor

### 3. Check Extension Output
- Press `Ctrl+Shift+P`
- Type "Output: Show Output Channels"
- Select "Dart" or "Flutter" to see if there are any errors

### 4. Manual Access to DevTools
Even if the button doesn't appear, you can still open DevTools:
- Press `Ctrl+Shift+P`
- Type "Dart: Open DevTools"
- Select "Dart: Open DevTools" from the list

### 5. Verify Flutter is Detected
- Press `Ctrl+Shift+P`
- Type "Flutter: Run Flutter Doctor"
- Check for any issues

### 6. Check Settings
The workspace settings in `.vscode/settings.json` should include:
```json
{
  "dart.openDevTools": "flutter",
  "dart.showDevTools": true
}
```
(These are already configured in your project)

## Alternative: Open DevTools in Browser

If the button still doesn't appear, you can manually open DevTools:
1. Start your app in debug mode (`F5`)
2. In the Debug Console, look for a message like:
   ```
   The Flutter DevTools debugger and profiler on hdx_mobile is available at: http://127.0.0.1:9100
   ```
3. Click that link or copy it to your browser

## Still Having Issues?

1. Make sure you're in a Flutter project (has `pubspec.yaml`)
2. Restart Cursor completely
3. Check that Flutter extension is up to date
4. Try running `flutter pub get` in the terminal

The key is: **The button only appears when your app is actively running in debug mode!**











