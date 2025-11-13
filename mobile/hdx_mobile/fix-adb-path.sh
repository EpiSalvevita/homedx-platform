#!/bin/bash
# Fix ADB path issue for Flutter in WSL2

ANDROID_SDK="/mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk"
PLATFORM_TOOLS="$ANDROID_SDK/platform-tools"

echo "Fixing ADB path for Flutter..."
echo ""

# Check if Windows ADB exists
if [ ! -f "$PLATFORM_TOOLS/adb.exe" ]; then
    echo "ERROR: ADB not found at $PLATFORM_TOOLS/adb.exe"
    exit 1
fi

# Create wrapper directory structure
mkdir -p ~/android-sdk-wrapper/platform-tools

# Create a wrapper script for adb
cat > ~/android-sdk-wrapper/platform-tools/adb << 'EOF'
#!/bin/bash
exec /mnt/c/Users/EpirotAlija/AppData/Local/Android/Sdk/platform-tools/adb.exe "$@"
EOF

chmod +x ~/android-sdk-wrapper/platform-tools/adb

echo "Created ADB wrapper at: ~/android-sdk-wrapper/platform-tools/adb"
echo ""
echo "Testing ADB wrapper..."
~/android-sdk-wrapper/platform-tools/adb devices

echo ""
echo "Now configure Flutter to use this SDK path:"
echo "flutter config --android-sdk ~/android-sdk-wrapper"











