#!/bin/bash

# homeDX Platform - Quick Deploy Script
# Automates the setup and launch of the platform

set -e  # Exit on error

SKIP_DEPLOY_BANNER=false
case "${1:-}" in
    connectivity|check-network|network) SKIP_DEPLOY_BANNER=true ;;
esac
if [ "$SKIP_DEPLOY_BANNER" != true ]; then
    echo "🚀 homeDX Platform - Quick Deploy"
    echo "=================================="
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    printf '%b✓%b %s\n' "$GREEN" "$NC" "$1"
}

print_error() {
    printf '%b✗%b %s\n' "$RED" "$NC" "$1"
}

# Use printf (not echo -e) so messages can contain ".\" paths without \c truncation.
print_info() {
    printf '%bℹ%b %s\n' "$YELLOW" "$NC" "$1"
}

# Windows LAN IPv4 for Flutter on a physical phone (WSL interop).
windows_wifi_lan_ip() {
    if ! command -v powershell.exe &>/dev/null; then
        echo ""
        return
    fi
    powershell.exe -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { \$_.InterfaceAlias -notmatch 'vEthernet|Virtual|VMware|Hyper-V' -and \$_.InterfaceAlias -match 'Wi-Fi|WiFi|WLAN|Ethernet' -and \$_.IPAddress -notlike '169.254.*' } | Select-Object -First 1).IPAddress" 2>/dev/null | tr -d '\r\n' | grep -E '^[0-9.]+$' || true
}

# POST endpoint used for smoke tests (same path the app uses under /gg-homedx-json/gg-api/v1).
BACKEND_PORT="${HOMEDX_BACKEND_PORT:-4000}"
BACKEND_STATUS_URL="http://127.0.0.1:${BACKEND_PORT}/gg-homedx-json/gg-api/v1/get-be-status-flags"

# True if Node can bind TCP on the given port (WSL + netsh 127.0.0.1:4000 portproxy can block 4000 with no ss row).
wsl_tcp_port_bindable() {
    node -e "require('net').createServer().listen($1,'0.0.0.0',function(){this.close();process.exit(0)}).on('error',()=>process.exit(1))" 2>/dev/null
}

# On WSL, Windows must forward 0.0.0.0:4000 → current WSL IP:4000 (see docs/WSL2_PORT_FORWARDING.md).
verify_portproxy_matches_wsl() {
    echo ""
    echo "🔌 Windows netsh portproxy → WSL (port 4000)"
    if ! command -v powershell.exe &>/dev/null; then
        print_info "powershell.exe not found — skipping portproxy check (not WSL-on-Windows?)"
        return 0
    fi
    local wsl_ip
    wsl_ip=$(ip -4 -o addr show eth0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    if [ -z "$wsl_ip" ]; then
        wsl_ip=$(hostname -I | awk '{print $1}')
    fi
    if [ -z "$wsl_ip" ]; then
        print_error "Could not read WSL IP (eth0 / hostname -I)."
        return 1
    fi
    local raw
    raw=$(powershell.exe -NoProfile -Command "netsh interface portproxy show all" 2>/dev/null | tr -d '\r' || true)
    local line
    line=$(echo "$raw" | grep -E '^[[:space:]]*0\.0\.0\.0[[:space:]]+4000[[:space:]]+' | head -1 || true)
    if [ -z "$line" ]; then
        print_error "No portproxy rule for 0.0.0.0:4000 → WSL. Run setup-wsl-port-forward.cmd as Admin on Windows, or from WSL: ./run-wsl-port-forward-elevated.sh"
        print_info "Details: docs/WSL2_PORT_FORWARDING.md"
        return 1
    fi
    local target
    target=$(echo "$line" | awk '{print $3}')
    if [ "$target" = "$wsl_ip" ]; then
        print_status "Port 4000 on Windows forwards to this WSL instance ($wsl_ip)"
        return 0
    fi
    # USB + Linux adb in WSL: reverse tunnels the phone's 127.0.0.1:4000 to WSL localhost (no Windows netsh).
    if command -v adb &>/dev/null; then
        local rev
        rev=$(env -u ADB_SERVER_SOCKET adb reverse --list 2>/dev/null || true)
        if echo "$rev" | grep -qE 'tcp:4000 tcp:[0-9]+'; then
            print_info "Portproxy targets ${target} (expected ${wsl_ip}), but adb reverse for device :4000 is active — API_BASE_URL=http://127.0.0.1:4000 works over USB with Linux adb (unset ADB_SERVER_SOCKET)."
            return 0
        fi
    fi
    print_error "Portproxy targets ${target} but this WSL IP is ${wsl_ip}. Run ./run-wsl-port-forward-elevated.sh from WSL or setup-wsl-port-forward.cmd as Administrator on Windows."
    print_info "WSL IPs change after restart; the script rewrites the netsh rules."
    return 1
}

verify_backend_listening() {
    local i=0
    local max=15
    while [ "$i" -lt "$max" ]; do
        if curl -sS --max-time 4 -X POST "$BACKEND_STATUS_URL" -H "Content-Type: application/json" -d '{}' >/dev/null 2>&1; then
            print_status "Backend is up in WSL at http://127.0.0.1:${BACKEND_PORT}"
            return 0
        fi
        i=$((i + 1))
        sleep 2
    done
    print_error "Backend did not respond on port ${BACKEND_PORT} in WSL after ~$((max * 2))s. The phone cannot log in until this works. Check: tail -50 backend.log"
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

# LAN + .env hints for Flutter (no portproxy check).
print_flutter_api_hints() {
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
            echo "   $(echo "$API_LINE" | tr -d '\r')"
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

# After backend starts: remind about portproxy + Flutter API_BASE_URL (common login timeout cause).
print_mobile_network_hints() {
    verify_portproxy_matches_wsl || true
    print_flutter_api_hints
}

# Check if we're in the right directory
if [ ! -f "README.md" ]; then
    print_error "Please run this script from the homeDX platform root directory"
    exit 1
fi

# Parse command line arguments
MODE="${1:-all}"  # Default to 'all'

case "$MODE" in
    "connectivity"|"check-network"|"network")
        echo "🌐 homeDX — network / port forwarding check (WSL + phone path)"
        echo "==========================================================="
        verify_portproxy_matches_wsl || true
        print_flutter_api_hints
        echo ""
        verify_backend_listening || print_info "Backend not responding on 127.0.0.1:${BACKEND_PORT} — start it with: ./deploy.sh backend"
        echo ""
        print_info "On Windows you can also run: .\\check-homedx-connectivity.ps1 (-UpdateMobileEnv to fix .env)"
        exit 0
        ;;
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
        echo "Usage: ./deploy.sh [all|backend|mobile|connectivity]"
        echo ""
        echo "  all           - Start both backend and mobile (default)"
        echo "  backend       - Start only the backend API"
        echo "  mobile        - Start only the mobile app"
        echo "  connectivity  - Verify Windows→WSL port 4000 portproxy, .env hint, backend smoke (no deploy)"
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
        if [ -z "${HOMEDX_BACKEND_PORT:-}" ] && [ "$BACKEND_PORT" = "4000" ] && ! wsl_tcp_port_bindable 4000; then
            BACKEND_PORT=4010
            BACKEND_STATUS_URL="http://127.0.0.1:${BACKEND_PORT}/gg-homedx-json/gg-api/v1/get-be-status-flags"
            print_info "Port 4000 is not bindable in this WSL session (often Windows netsh 127.0.0.1:4000 → WSL); using PORT=${BACKEND_PORT}"
        fi
        export PORT="$BACKEND_PORT"
        cd backend
        npm run start:dev > ../backend.log 2>&1 &
        BACKEND_PID=$!
        echo $BACKEND_PID > ../backend.pid
        cd ..
        print_status "Backend started (PID: $BACKEND_PID, logs: backend.log)"
        
        # Wait a bit for backend to initialize
        sleep 3
    fi
    if command -v adb &>/dev/null; then
        env -u ADB_SERVER_SOCKET adb reverse --remove tcp:4000 2>/dev/null || true
        if env -u ADB_SERVER_SOCKET adb reverse "tcp:4000" "tcp:${BACKEND_PORT}" >/dev/null 2>&1; then
            print_status "adb reverse tcp:4000 tcp:${BACKEND_PORT} (Flutter can use API_BASE_URL=http://127.0.0.1:4000 on device)"
        fi
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
    echo "   Health: http://localhost:${BACKEND_PORT} (from WSL); phone uses Windows LAN IP :4000 or USB adb reverse to :${BACKEND_PORT}"
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

