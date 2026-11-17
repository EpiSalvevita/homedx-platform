# iOS setup (Mac, free Apple ID)

How to build and run the homeDX app on a physical iPhone with the BIOSYNEX
CubeReader SDK, without a paid Apple Developer account. Minimum iOS is 17.

## 1. Tools

1. Install **Xcode** from the Mac App Store (free). Open it once and accept the license.
2. `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
3. Install **CocoaPods**: `brew install cocoapods` (or `sudo gem install cocoapods`).
4. Install **Flutter** (version pinned in CI: 3.35.6) and run `flutter doctor`.

## 2. Cube SDK and assets

The SDK is proprietary and is not in git. In `frontend/mobile/hdx_mobile/ios/CubeSDK/`:

- Unzip `CubeReader.xcframework` from the BIOSYNEX `iOS-CubeReader-1.3.0.xcframework.zip`.
- Copy `cube_license.dat`, `cube_test_config.bin` and `CRP_*.bin` from
  `android/app/src/main/assets` into `ios/CubeSDK/assets/`.

Details: `frontend/mobile/hdx_mobile/ios/CubeSDK/README.md`.

## 3. Install pods

```
cd frontend/mobile/hdx_mobile
cp .env.example .env     # if you have no .env yet
flutter pub get
cd ios && pod install
```

## 4. Signing with a free Apple ID

1. `open ios/Runner.xcworkspace` (always the workspace, not the project).
2. Select the Runner target, then Signing & Capabilities.
3. Xcode > Settings > Accounts: add your Apple ID.
4. Under Signing, choose your **Personal Team**. The bundle id is `com.homedx.app`;
   if Xcode reports it as taken, use a unique suffix for local testing only
   (the Cube license may then be rejected, see below).

## 5. iPhone

1. Connect the iPhone and trust the computer.
2. Settings > Privacy & Security > **Developer Mode** > on (the phone restarts).
3. After the first install: Settings > General > VPN & Device Management > trust your developer profile.
4. `flutter run --release` from `frontend/mobile/hdx_mobile`.

## Limits and troubleshooting

- Free provisioning **expires after 7 days**; rebuild and reinstall.
- The **Simulator has no Bluetooth**, so the Cube cannot be used there.
- Without the xcframework the app builds, but the Cube SDK reports as unavailable.
- If the license is rejected (`licenseValid=false`), the Android license may not be
  valid on iOS. Ask BIOSYNEX for an iOS license bound to bundle id `com.homedx.app`.
