#!/bin/bash
# Script to start Android emulator from WSL
# This will start the emulator on Windows, which can then be detected by Flutter in WSL

# Detect Windows username from WSL path
WINDOWS_USER=$(whoami.exe 2>/dev/null | tr -d '\r' || echo "epiro")
ANDROID_SDK="/mnt/c/Users/${WINDOWS_USER}/AppData/Local/Android/Sdk"
EMULATOR_PATH="${ANDROID_SDK}/emulator/emulator.exe"

echo "Starting Android emulator from WSL..."
echo ""

# Check if emulator executable exists
if [ ! -f "$EMULATOR_PATH" ]; then
    echo "ERROR: Emulator not found at: $EMULATOR_PATH"
    echo ""
    echo "Please update WINDOWS_USER in this script or ensure Android SDK is installed."
    echo "Default Windows username detected: $WINDOWS_USER"
    exit 1
fi

# List available AVDs
echo "Available Android Virtual Devices:"
cmd.exe /c "\"${EMULATOR_PATH}\" -list-avds" 2>/dev/null | grep -v "^$" || echo "  (No AVDs found)"
echo ""

# Use first available AVD or allow user to specify
AVD_NAME="${1:-Medium_Phone_API_36.0}"

echo "Starting emulator: $AVD_NAME"
echo "This will open the emulator on Windows."
echo "Wait for the emulator to fully boot, then run 'flutter devices' to verify."
echo ""

# Start the emulator on Windows
cmd.exe /c "\"${EMULATOR_PATH}\" -avd ${AVD_NAME}" > /dev/null 2>&1 &

echo "Emulator is starting..."
echo "Waiting 15 seconds before checking devices..."
sleep 15

echo ""
echo "Checking for connected devices..."
export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037
flutter devices

echo ""
echo "If the emulator doesn't appear, wait a bit longer for it to fully boot,"
echo "then run 'flutter devices' again."
echo ""
echo "Usage: $0 [AVD_NAME]"
echo "Example: $0 Medium_Phone_API_36.0"











