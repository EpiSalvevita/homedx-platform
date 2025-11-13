#!/bin/bash
# Script to configure ADB in WSL2 to work with Windows Android emulator

echo "Setting up ADB for WSL2 to connect to Windows Android emulator..."
echo ""

# Get Windows host IP
WINDOWS_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
echo "Windows host IP: $WINDOWS_IP"

# Kill any local ADB server
echo "Stopping local ADB server..."
adb kill-server 2>/dev/null || true

# Set ADB to use Windows server
export ADB_SERVER_SOCKET=tcp:$WINDOWS_IP:5037

echo ""
echo "Testing ADB connection..."
adb devices

echo ""
echo "Testing Flutter device detection..."
flutter devices

echo ""
echo "If devices are shown above, add this to your ~/.bashrc:"
echo "export ADB_SERVER_SOCKET=tcp:\$(cat /etc/resolv.conf | grep nameserver | awk '{print \$2}'):5037"











