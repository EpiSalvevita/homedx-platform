# iOS setup (Mac, free Apple ID)

How to build and run the homeDX app on a physical iPhone with the BIOSYNEX
CubeReader SDK, without a paid Apple Developer account. Minimum iOS is 17.
Requires Xcode 15 or newer.

## 1. Install tools

1. Install **Xcode** (15+) from the Mac App Store (free). Open it once and accept the license.
2. `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
3. Install **CocoaPods**: `brew install cocoapods` (or `sudo gem install cocoapods`).
4. Install **Flutter** (version pinned in CI: 3.35.6) and run `flutter doctor`.

## 2. Cube SDK and assets (local, not in git)

The SDK and license are proprietary and are never committed. In `frontend/mobile/hdx_mobile/ios/CubeSDK/`:

- Unzip `CubeReader.xcframework` from the BIOSYNEX `iOS-CubeReader-1.3.0.xcframework.zip`.
- Put `cube_license.dat`, `cube_test_config.bin` and `CRP_*.bin` into `ios/CubeSDK/assets/`.
  Obtain them from BIOSYNEX or the team's secure store.

Details: `frontend/mobile/hdx_mobile/ios/CubeSDK/README.md`.

## 3. Apple ID in Xcode

Xcode > Settings > Accounts: add your Apple ID (this creates a free Personal Team).

## 4. Connect the iPhone

1. Connect the iPhone and trust the computer.
2. Enable **Developer Mode**: Settings > Privacy & Security > Developer Mode > on
   (the entry only appears after the phone has been connected to Xcode; the phone restarts).

## 5. Install pods

```
cd frontend/mobile/hdx_mobile
cp .env.example .env     # if you have no .env yet
flutter pub get
cd ios && pod install
```

Re-run `pod install` after changing anything in `ios/CubeSDK` (for example the assets).

The first `pod install` on a Mac modifies `Runner.xcodeproj/project.pbxproj` and the
workspace and creates `Podfile.lock`. Commit those once, but never commit a changed
bundle id or signing team.

## 6. Signing and run

1. `open ios/Runner.xcworkspace` (always the workspace, not the project).
2. Runner target > Signing & Capabilities > Team: your **Personal Team**. The bundle id is
   `com.homedx.app`; if Xcode reports it as taken, use a unique suffix for local testing
   only (the Cube license may then be rejected, see below). Do not commit that change.
3. After the first install: Settings > General > VPN & Device Management > trust your developer profile.
4. `flutter run --release` from `frontend/mobile/hdx_mobile`.

## Limits and troubleshooting

- Free provisioning **expires after 7 days**; rebuild and reinstall.
- Free accounts allow 3 apps per device and 10 App IDs per 7 days.
- The **Simulator has no Bluetooth**, so the Cube cannot be used there.
- Without the xcframework the app builds, but the Cube SDK reports as unavailable
  (once the Cube bridge PR lands).
- If the license is rejected (`licenseValid=false`), ask BIOSYNEX for an iOS license
  bound to bundle id `com.homedx.app`.
