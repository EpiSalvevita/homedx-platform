#!/usr/bin/env bash
# Start or update the HomeDX stack on the NAS (or local smoke test).
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

if [ ! -f .env ]; then
  echo "Copy .env.example to .env and edit POSTGRES_PASSWORD, JWT_SECRET, APP_URL"
  cp .env.example .env
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "Docker Compose not found. Install docker compose plugin or docker-compose."
  exit 1
fi

if [ ! -f web/index.html ]; then
  echo "web/ is empty. Run: HOMEDX_NAS_IP=<your-nas-ip> ./build-artifacts.sh"
  exit 1
fi

echo "Starting HomeDX stack ($COMPOSE)..."
$COMPOSE up -d --build

echo ""
echo "Web:    http://<NAS_IP>:${WEB_PORT:-8080}/"
echo "API:    http://<NAS_IP>:${BACKEND_PORT:-4000}/"
echo "APK:    http://<NAS_IP>:${WEB_PORT:-8080}/downloads/hdx-mobile.apk"
echo "Logs:   $COMPOSE logs -f backend"
