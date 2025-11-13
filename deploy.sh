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
fi

# Start Mobile App
if [ "$START_MOBILE" = true ]; then
    echo ""
    echo "📱 Starting Mobile App..."
    
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
    echo "   Health: http://localhost:4000"
fi

if [ "$START_MOBILE" = true ]; then
    echo ""
    echo "📱 Mobile App:"
    echo "   Status: Metro bundler running (PID: $(cat metro.pid 2>/dev/null || echo 'unknown'))"
    echo "   Logs:   metro.log"
    echo ""
    echo "To install on Android device:"
    echo "   1. Start an emulator in Android Studio, OR"
    echo "   2. Connect a physical device via USB"
    echo "   3. Run: cd mobile && npx react-native run-android"
fi

echo ""
echo "🔑 Test Credentials:"
echo "   Email: epirotalija@gmail.com"
echo "   Password: espex260"
echo ""

echo "⚠️  To stop services, run: ./stop.sh"
echo ""

