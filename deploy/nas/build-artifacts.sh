#!/usr/bin/env bash
# Build Flutter web + Android APK for NAS LAN deployment.
# Temporarily sets the Flutter .env for the build, then restores your local copy
# (same tree is used for WSL/web/phone day-to-day).
# Usage: HOMEDX_NAS_IP=192.168.1.50 ./build-artifacts.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../" && pwd)"
FLUTTER_APP="$ROOT/frontend/mobile/hdx_mobile"
NAS_DIR="$(cd "$(dirname "$0")" && pwd)"
NAS_IP="${HOMEDX_NAS_IP:-192.168.1.50}"
ENV_FILE="$FLUTTER_APP/.env"
ENV_BACKUP=""
HAD_ENV=0

restore_env() {
  if [ "$HAD_ENV" -eq 1 ] && [ -n "$ENV_BACKUP" ] && [ -f "$ENV_BACKUP" ]; then
    mv -f "$ENV_BACKUP" "$ENV_FILE"
    echo "Restored local Flutter .env"
  elif [ "$HAD_ENV" -eq 0 ]; then
    rm -f "$ENV_FILE"
    echo "Removed temporary NAS Flutter .env (no prior local .env existed)"
  fi
}
trap restore_env EXIT

echo "Building for NAS API at http://${NAS_IP}:4000"

mkdir -p "$NAS_DIR/web" "$NAS_DIR/downloads"

if [ -f "$ENV_FILE" ]; then
  HAD_ENV=1
  ENV_BACKUP="$(mktemp "${TMPDIR:-/tmp}/hdx_mobile.env.XXXXXX")"
  cp -a "$ENV_FILE" "$ENV_BACKUP"
  echo "Backed up Flutter .env → will restore after build"
fi

# Flutter .env is bundled into web/APK at build time
cat > "$ENV_FILE" <<EOF
API_BASE_URL=http://${NAS_IP}:4000
CUBE_VERBOSE=false
CUBE_USE_TIMER=true
EOF

cd "$FLUTTER_APP"
flutter pub get
flutter build web --release
flutter build apk --release

rm -rf "$NAS_DIR/web"/*
cp -a build/web/. "$NAS_DIR/web/"

cp build/app/outputs/flutter-apk/app-release.apk "$NAS_DIR/downloads/hdx-mobile.apk"

echo ""
echo "Artifacts ready in deploy/nas/:"
echo "  web/          → Flutter web (nginx)"
echo "  downloads/hdx-mobile.apk"
echo ""
echo "Colleagues:"
echo "  Web:  http://${NAS_IP}:${WEB_PORT:-8080}/"
echo "  APK:  http://${NAS_IP}:${WEB_PORT:-8080}/downloads/hdx-mobile.apk"
