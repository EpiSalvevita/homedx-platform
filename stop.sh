#!/bin/bash

# homeDX Platform - Stop Script
# Stops all running services started by deploy.sh

set -e

echo "🛑 Stopping homeDX Platform Services"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Stop backend if running
if [ -f backend.pid ]; then
    BACKEND_PID=$(cat backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}Stopping backend (PID: $BACKEND_PID)${NC}"
        kill $BACKEND_PID 2>/dev/null || true
        rm backend.pid
        echo -e "${GREEN}✓ Backend stopped${NC}"
    else
        rm backend.pid
    fi
fi

# Stop Metro if running
if [ -f metro.pid ]; then
    METRO_PID=$(cat metro.pid)
    if ps -p $METRO_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}Stopping Metro bundler (PID: $METRO_PID)${NC}"
        kill $METRO_PID 2>/dev/null || true
        rm metro.pid
        echo -e "${GREEN}✓ Metro stopped${NC}"
    else
        rm metro.pid
    fi
fi

# Also kill any remaining processes
pkill -f "npm run start:dev" 2>/dev/null && echo -e "${GREEN}✓ Stopped remaining backend processes${NC}" || true
pkill -f "react-native start" 2>/dev/null && echo -e "${GREEN}✓ Stopped remaining Metro processes${NC}" || true

echo ""
echo "✅ All services stopped"
echo ""

