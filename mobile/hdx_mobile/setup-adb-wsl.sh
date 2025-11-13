#!/bin/bash
# Script to configure ADB in WSL2 to work with Windows Android emulator
# This script sets up ADB connection and creates the Flutter ADB wrapper

echo "Setting up ADB for WSL2 to connect to Windows Android emulator..."
echo ""

# Detect Windows username
WINDOWS_USER=$(whoami.exe 2>/dev/null | tr -d '\r' || echo "epiro")
ANDROID_SDK="/mnt/c/Users/${WINDOWS_USER}/AppData/Local/Android/Sdk"
ADB_EXE="${ANDROID_SDK}/platform-tools/adb.exe"

# Get Windows host IP
WINDOWS_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
echo "Windows host IP: $WINDOWS_IP"
echo "Windows username: $WINDOWS_USER"
echo ""

# Check if Windows ADB exists
if [ ! -f "$ADB_EXE" ]; then
    echo "WARNING: Windows ADB not found at: $ADB_EXE"
    echo "Please verify your Android SDK installation path."
    echo ""
fi

# Kill any local ADB server
echo "Stopping local ADB server..."
$ADB_EXE kill-server 2>/dev/null || true

# Set ADB to use Windows server
export ADB_SERVER_SOCKET=tcp:$WINDOWS_IP:5037

# Create ADB wrapper for Flutter
echo ""
echo "Creating ADB wrapper for Flutter..."
mkdir -p ~/android-sdk-wrapper/platform-tools

cat > ~/android-sdk-wrapper/platform-tools/adb << EOF
#!/bin/bash
export ADB_SERVER_SOCKET=tcp:\$(cat /etc/resolv.conf | grep nameserver | awk '{print \$2}'):5037
exec ${ADB_EXE} "\$@"
EOF

chmod +x ~/android-sdk-wrapper/platform-tools/adb
echo "ADB wrapper created at: ~/android-sdk-wrapper/platform-tools/adb"

# Copy Android SDK licenses to wrapper
echo ""
echo "Copying Android SDK licenses to wrapper..."
mkdir -p ~/android-sdk-wrapper/licenses
if [ -d "${ANDROID_SDK}/licenses" ]; then
    cp -r "${ANDROID_SDK}/licenses"/* ~/android-sdk-wrapper/licenses/ 2>/dev/null
    echo "Licenses copied successfully"
else
    echo "WARNING: License directory not found at ${ANDROID_SDK}/licenses"
    echo "You may need to accept licenses manually using Android Studio SDK Manager"
fi

# Configure Flutter to use the wrapper
echo ""
echo "Configuring Flutter to use ADB wrapper..."
flutter config --android-sdk ~/android-sdk-wrapper

# Add to .bashrc if not already present
if ! grep -q "ADB_SERVER_SOCKET" ~/.bashrc; then
    echo ""
    echo "Adding ADB_SERVER_SOCKET to ~/.bashrc..."
    echo "" >> ~/.bashrc
    echo "# Android ADB configuration for WSL2 - Connect to Windows ADB server" >> ~/.bashrc
    echo "export ADB_SERVER_SOCKET=tcp:\$(cat /etc/resolv.conf | grep nameserver | awk '{print \$2}'):5037" >> ~/.bashrc
    echo "Configuration added to ~/.bashrc"
    echo "Run 'source ~/.bashrc' or restart your terminal to apply changes."
else
    echo ""
    echo "ADB_SERVER_SOCKET already configured in ~/.bashrc"
fi

echo ""
echo "Testing ADB connection..."
~/android-sdk-wrapper/platform-tools/adb devices

echo ""
echo "Testing Flutter device detection..."
flutter devices

echo ""
echo "Setup complete! Make sure your Android emulator is running on Windows,"
echo "then run 'flutter devices' to verify detection."











