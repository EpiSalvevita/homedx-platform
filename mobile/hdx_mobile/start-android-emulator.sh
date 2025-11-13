#!/bin/bash
# Script to start Android emulator from WSL
# This will start the emulator on Windows, which can then be detected by Flutter in WSL

echo "Starting Android emulator from WSL..."
echo ""
echo "This will open the emulator on Windows."
echo "Wait for the emulator to fully boot, then run 'flutter devices' to verify."
echo ""

# Start the emulator on Windows
cmd.exe /c "C:\Users\EpirotAlija\AppData\Local\Android\Sdk\emulator\emulator.exe -avd Medium_Phone_API_36.1" &

echo "Emulator is starting..."
echo "Waiting 10 seconds before checking devices..."
sleep 10

echo ""
echo "Checking for connected devices..."
flutter devices

echo ""
echo "If the emulator doesn't appear, wait a bit longer for it to fully boot,"
echo "then run 'flutter devices' again."











