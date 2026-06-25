#!/usr/bin/env bash
# Serve Flutter web release with SPA routing (path URLs like /home, /doctors work).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${1:-8080}"

if [ ! -d "$ROOT/build/web" ]; then
  echo "Missing build/web — run: flutter build web --release" >&2
  exit 1
fi

fuser -k "${PORT}/tcp" 2>/dev/null || true
sleep 1
exec python3 "$ROOT/scripts/serve_web.py" --port "$PORT"
