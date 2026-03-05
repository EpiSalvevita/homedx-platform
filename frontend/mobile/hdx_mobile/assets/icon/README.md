# App Icon Setup

Place your HDX logo image here:

1. **app_icon.png** - Main app icon (1024x1024px recommended)
   - Should be a square image with the HDX logo
   - The logo should be centered
   - Background: Light teal (#B2DFDB)

2. **app_icon_foreground.png** - For Android adaptive icon (1024x1024px)
   - Just the HDX logo without background (transparent background)
   - Will be placed on the teal background

After placing the images, run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will generate all required icon sizes for Android and iOS.




