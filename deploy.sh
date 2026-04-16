#!/bin/bash

# homeDX Platform - Quick Deploy Script
# Automates the setup and launch of the platform

set -e  # Exit on error

echo "🚀 homeDX Platform - Quick Deploy"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Windows LAN IPv4 for Flutter on a physical phone (WSL interop).
windows_wifi_lan_ip() {
    if ! command -v powershell.exe &>/dev/null; then
        echo ""
        return
    fi
    powershell.exe -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { \$_.InterfaceAlias -match 'Wi-Fi|WiFi|WLAN|Ethernet' -and \$_.IPAddress -notlike '169.254.*' } | Select-Object -First 1).IPAddress" 2>/dev/null | tr -d '\r\n' | grep -E '^[0-9.]+$' || true
}

# POST endpoint used for smoke tests (same path the app uses under /gg-homedx-json/gg-api/v1).
BACKEND_STATUS_URL="http://127.0.0.1:4000/gg-homedx-json/gg-api/v1/get-be-status-flags"

verify_backend_listening() {
    local i=0
    local max=15
    while [ "$i" -lt "$max" ]; do
        if curl -sS --max-time 4 -X POST "$BACKEND_STATUS_URL" -H "Content-Type: application/json" -d '{}' >/dev/null 2>&1; then
            print_status "Backend is up in WSL at http://127.0.0.1:4000"
            return 0
        fi
        i=$((i + 1))
        sleep 2
    done
    print_error "Backend did not respond on port 4000 in WSL after ~$((max * 2))s. The phone cannot log in until this works. Check: tail -50 backend.log"
    return 1
}

# Optional: same URL the phone uses; may fail from WSL even when the phone works (hairpin routing).
probe_windows_lan_from_wsl() {
    local LAN="$1"
    [ -z "$LAN" ] && return
    local url="http://${LAN}:4000/gg-homedx-json/gg-api/v1/get-be-status-flags"
    if curl -sS --max-time 5 -X POST "$url" -H "Content-Type: application/json" -d '{}' >/dev/null 2>&1; then
        print_status "http://${LAN}:4000 reachable from WSL (matches typical Flutter API_BASE_URL for Wi‑Fi)"
    else
        print_info "Could not reach http://${LAN}:4000 from WSL (sometimes normal). If login still times out on the phone: run setup-wsl-port-forward.cmd as Admin on Windows; then .\\check-homedx-connectivity.ps1"
    fi
}

# After backend starts: remind about portproxy + Flutter API_BASE_URL (common login timeout cause).
print_mobile_network_hints() {
    echo ""
    echo "📶 Phone / Flutter → backend (port 4000)"
    LAN="$(windows_wifi_lan_ip)"
    if [ -n "$LAN" ]; then
        print_info "Windows Wi‑Fi/Ethernet IPv4 (use in Flutter .env): http://${LAN}:4000"
    else
        print_info "Could not read Windows LAN IP from WSL; on Windows run: ipconfig (use Wi‑Fi IPv4)"
    fi
    ENV_FILE="frontend/mobile/hdx_mobile/.env"
    if [ -f "$ENV_FILE" ]; then
        API_LINE=$(grep -E '^[[:space:]]*API_BASE_URL=' "$ENV_FILE" | head -1 || true)
        if [ -n "$API_LINE" ]; then
            echo "   $API_LINE"
            if echo "$API_LINE" | grep -qiE 'localhost|127\.0\.0\.1'; then
                print_info "Physical device: localhost only works with USB adb reverse tcp:4000 tcp:4000"
            fi
            if [ -n "$LAN" ] && ! echo "$API_LINE" | grep -qF "$LAN"; then
                print_info "If login fails, API_BASE_URL may be stale. On Windows: .\\check-homedx-connectivity.ps1 -UpdateMobileEnv"
            fi
        else
            print_info "Add API_BASE_URL to $ENV_FILE (see .env.example)"
        fi
    fi
    print_info "After WSL restart, rerun setup-wsl-port-forward.cmd as Admin (WSL IP changes)."
    print_info "Details: docs/WSL2_PORT_FORWARDING.md"
    probe_windows_lan_from_wsl "$LAN"
}

# Check if we're in the right directory
if [ ! -f "README.md" ]; then
    print_error "Please run this script from the homeDX platform root directory"
    exit 1
fi

# Parse command line arguments
MODE="${1:-all}"  # Default to 'all'

case "$MODE" in
    "all")
        START_BACKEND=true
        START_MOBILE=true
        ;;
    "backend"|"api"|"server")
        START_BACKEND=true
        START_MOBILE=false
        ;;
    "mobile"|"app"|"android")
        START_BACKEND=false
        START_MOBILE=true
        ;;
    *)
        echo "Usage: ./deploy.sh [all|backend|mobile]"
        echo ""
        echo "  all     - Start both backend and mobile (default)"
        echo "  backend - Start only the backend API"
        echo "  mobile  - Start only the mobile app"
        exit 1
        ;;
esac

FLUTTER_APP="frontend/mobile/hdx_mobile"

# Start PostgreSQL Database
if [ "$START_BACKEND" = true ]; then
    echo ""
    echo "📦 Starting PostgreSQL Database..."
    if docker ps | grep -q hdx-postgres; then
        print_status "PostgreSQL container already running"
    else
        docker start hdx-postgres || {
            print_error "Failed to start PostgreSQL container"
            print_info "Make sure Docker is running and the hdx-postgres container exists"
            exit 1
        }
        print_status "PostgreSQL started"
    fi
fi

# Start Backend API
if [ "$START_BACKEND" = true ]; then
    echo ""
    echo "🔧 Starting Backend API..."
    
    # Check if backend dependencies are installed
    if [ ! -d "backend/node_modules" ]; then
        print_info "Installing backend dependencies..."
        cd backend
        npm install --legacy-peer-deps
        cd ..
        print_status "Backend dependencies installed"
    fi
    
    # Check if backend is already running
    if pgrep -f "npm run start:dev" > /dev/null; then
        print_status "Backend already running"
    else
        print_info "Starting backend in development mode..."
        cd backend
        npm run start:dev > ../backend.log 2>&1 &
        BACKEND_PID=$!
        echo $BACKEND_PID > ../backend.pid
        cd ..
        print_status "Backend started (PID: $BACKEND_PID, logs: backend.log)"
        
        # Wait a bit for backend to initialize
        sleep 3
    fi
    verify_backend_listening || true
    print_mobile_network_hints
fi

# Start Mobile App
if [ "$START_MOBILE" = true ]; then
    echo ""
    echo "📱 Starting Mobile App..."

    if [ -f "$FLUTTER_APP/pubspec.yaml" ]; then
        print_status "Flutter app found at $FLUTTER_APP"
        if [ -f "$FLUTTER_APP/.env" ]; then
            grep -E '^[[:space:]]*API_BASE_URL=' "$FLUTTER_APP/.env" | head -1 || true
        fi
        print_info "To run on a device: cd $FLUTTER_APP && flutter run"
        print_info "Release install: cd $FLUTTER_APP && flutter run --release -d <deviceId>"
    elif [ ! -f "mobile/package.json" ]; then
        print_info "No Flutter app at $FLUTTER_APP/pubspec.yaml and no React Native at mobile/package.json."
        print_info "Start the Flutter client manually from frontend/mobile/hdx_mobile when ready."
    else
        # Check if mobile dependencies are installed
        if [ ! -d "mobile/node_modules" ]; then
            print_info "Installing mobile dependencies..."
            cd mobile
            export NODE_OPTIONS="--openssl-legacy-provider"
            npm install --legacy-peer-deps
            cd ..
            print_status "Mobile dependencies installed"
        fi
        
        # Start Metro bundler
        if pgrep -f "react-native start" > /dev/null; then
            print_status "Metro bundler already running"
        else
            print_info "Starting Metro bundler..."
            cd mobile
            export NODE_OPTIONS="--openssl-legacy-provider"
            npx react-native start > ../metro.log 2>&1 &
            METRO_PID=$!
            echo $METRO_PID > ../metro.pid
            cd ..
            print_status "Metro started (PID: $METRO_PID, logs: metro.log)"
            
            # Wait for Metro to initialize
            sleep 5
        fi
        
        # Try to run the Android app
        echo ""
        print_info "Attempting to build and run Android app..."
        
        cd mobile
        export NODE_OPTIONS="--openssl-legacy-provider"
        
        # Check for connected devices
        if command -v adb &> /dev/null; then
            DEVICES=$(adb devices | grep -v "List" | grep "device" | wc -l)
            if [ "$DEVICES" -gt 0 ]; then
                print_status "Android device/emulator detected"
                npx react-native run-android
            else
                print_info "No Android device/emulator detected"
                print_info "Building APK only (you can install it later)"
                
                cd android
                ./gradlew assembleDebug
                cd ..
                
                APK_PATH="./android/app/build/outputs/apk/debug/app-debug.apk"
                if [ -f "$APK_PATH" ]; then
                    print_status "APK built successfully at:"
                    echo "   $(pwd)/$APK_PATH"
                fi
            fi
        else
            print_info "adb not found, building APK only"
            cd android
            ./gradlew assembleDebug
            cd ..
            
            APK_PATH="./android/app/build/outputs/apk/debug/app-debug.apk"
            if [ -f "$APK_PATH" ]; then
                print_status "APK built successfully at:"
                echo "   $(pwd)/$APK_PATH"
            fi
        fi
        
        cd ..
    fi
    if [ "$START_BACKEND" = false ] && [ -f "$FLUTTER_APP/pubspec.yaml" ]; then
        print_mobile_network_hints
    fi
fi

# Summary
echo ""
echo "=================================="
echo "✅ homeDX Platform Deploy Complete!"
echo "=================================="

if [ "$START_BACKEND" = true ]; then
    echo ""
    echo "📊 Backend API:"
    echo "   Status: Running (PID: $(cat backend.pid 2>/dev/null || echo 'unknown'))"
    echo "   Logs:   backend.log"
    echo "   Health: http://localhost:4000 (from WSL); phone uses Windows LAN IP :4000"
fi

if [ "$START_MOBILE" = true ]; then
    echo ""
    echo "📱 Mobile App:"
    if [ -f "frontend/mobile/hdx_mobile/pubspec.yaml" ]; then
        echo "   Flutter: cd frontend/mobile/hdx_mobile && flutter run"
    elif [ -f "metro.pid" ]; then
        echo "   Metro: PID $(cat metro.pid 2>/dev/null || echo 'unknown'), logs: metro.log"
        echo "   Android: cd mobile && npx react-native run-android"
    else
        echo "   See messages above for Flutter or legacy React Native paths."
    fi
fi

echo ""
echo "🔑 Test Credentials:"
echo "   Email: epirotalija@gmail.com"
echo "   Password: espex260"
echo ""

echo "⚠️  To stop services, run: ./stop.sh"
echo ""

