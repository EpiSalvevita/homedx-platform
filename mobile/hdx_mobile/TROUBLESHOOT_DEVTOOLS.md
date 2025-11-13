# Troubleshooting Dart DevTools Button in Cursor

## Current Status
The Dart DevTools button should appear in the status bar when debugging, but it's not showing up.

## Quick Steps to Try:

### 1. Verify Extension is Active
- Press `Ctrl+Shift+X` to open Extensions
- Search for "Dart" - ensure it's **installed AND enabled** (not disabled)
- Search for "Flutter" - ensure it's **installed AND enabled**
- If either shows "Enable" button, click it
- Reload Cursor after enabling

### 2. Check Extension Output for Errors
- Press `Ctrl+Shift+P`
- Type: `Output: Show Output Channels`
- Select **"Dart"** from the list
- Look for any error messages
- Also check **"Flutter"** output channel

### 3. Try Manual DevTools Access
Even without the button, you can open DevTools:

**Method A: Command Palette**
1. Press `Ctrl+Shift+P`
2. Type: `Dart: Open DevTools`
3. Select it from the list

**Method B: From Terminal**
1. Start your app: `flutter run -d linux`
2. Look for a line like: `The Flutter DevTools debugger and profiler on hdx_mobile is available at: http://127.0.0.1:9100`
3. Copy that URL and open it in your browser

### 4. Check Status Bar Visibility
- Make sure the status bar is visible (bottom of Cursor)
- Try: View → Appearance → Status Bar (if it exists)
- The button might be hidden - try right-clicking the status bar to see if there are visibility options

### 5. Verify Debug Session is Active
The button ONLY appears when:
- App is running in **debug mode** (not release mode)
- Started via **F5** or Debug panel (not `flutter run` in terminal)
- Debug session is actively connected

### 6. Check Cursor-Specific Issues
Cursor is based on VS Code but may have differences:
- Try restarting Cursor completely
- Check Cursor's extension compatibility
- Update Cursor to latest version if available

### 7. Alternative: Use Flutter DevTools Directly
If the button never appears, you can use DevTools standalone:

1. Install DevTools globally:
   ```bash
   flutter pub global activate devtools
   ```

2. Start your app:
   ```bash
   flutter run -d linux
   ```

3. In another terminal, start DevTools:
   ```bash
   flutter pub global run devtools
   ```

4. It will open in your browser automatically

## Debugging Steps

1. **Check if extension recognizes the project:**
   - Press `Ctrl+Shift+P`
   - Type: `Dart: Get SDK Info`
   - This should show Flutter SDK information if extension is working

2. **Verify debug configuration:**
   - Open `.vscode/launch.json` (should exist now)
   - Press `F5` - make sure it uses the "hdx_mobile" configuration
   - Check the Debug Console for any errors

3. **Test with a simple run:**
   - Press `F5`
   - Wait for app to start
   - Check bottom-right status bar area
   - Look for ANY buttons/icons (might be small or hidden)

## If Nothing Works

The DevTools functionality is still available even without the button:
- Use Command Palette (`Ctrl+Shift+P` → `Dart: Open DevTools`)
- Use the URL method (shown in terminal output)
- Use standalone DevTools (see Method 7 above)

The button is just a convenience shortcut - the actual DevTools functionality should work regardless.











