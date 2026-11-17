# CubeSDK (local, not in git)

The BIOSYNEX CubeReader SDK is proprietary and must never be committed. The
Podfile links it only if `CubeReader.xcframework` exists in this folder.

Place the files like this:

```
ios/CubeSDK/
  CubeReader.podspec          (in git)
  CubeReader.xcframework/     from the BIOSYNEX zip iOS-CubeReader-1.3.0.xcframework.zip
  assets/
    cube_license.dat          obtain from BIOSYNEX / secure store
    cube_test_config.bin      obtain from BIOSYNEX / secure store
    CRP_*.bin                 obtain from BIOSYNEX / secure store
```

Then run `cd ios && pod install`. Without the xcframework the app still builds,
but the Cube bridge reports the SDK as unavailable (once the Cube bridge PR lands).

See `docs/IOS_SETUP.md` for the full Mac setup.
