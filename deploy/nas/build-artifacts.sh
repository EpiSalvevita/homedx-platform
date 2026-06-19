#!/usr/bin/env bash
# Build Flutter web + Android APK for NAS LAN deployment.
# Usage: HOMEDX_NAS_IP=192.168.1.50 ./build-artifacts.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../" && pwd)"
FLUTTER_APP="$ROOT/frontend/mobile/hdx_mobile"
NAS_DIR="$(cd "$(dirname "$0")" && pwd)"
NAS_IP="${HOMEDX_NAS_IP:-192.168.1.50}"

echo "Building for NAS API at http://${NAS_IP}:4000"

mkdir -p "$NAS_DIR/web" "$NAS_DIR/downloads"

# Flutter .env is bundled into web/APK at build time
cat > "$FLUTTER_APP/.env" <<EOF
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
