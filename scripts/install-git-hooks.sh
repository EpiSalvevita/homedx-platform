#!/usr/bin/env bash
# Configure local git hooks and optionally install gitleaks.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

git config core.hooksPath scripts/git-hooks
chmod +x scripts/git-hooks/pre-commit
echo "Git hooks path set to scripts/git-hooks"

if command -v gitleaks >/dev/null 2>&1; then
  echo "gitleaks already installed: $(gitleaks version)"
  exit 0
fi

echo "Installing gitleaks binary to scripts/gitleaks ..."
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$ARCH" in
  x86_64) GL_ARCH="x64" ;;
  aarch64|arm64) GL_ARCH="arm64" ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

VERSION="8.24.2"
URL="https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/gitleaks_${VERSION}_${OS}_${GL_ARCH}.tar.gz"
TMP="$(mktemp -d)"
curl -fsSL "$URL" | tar -xz -C "$TMP"
mv "$TMP/gitleaks" scripts/gitleaks
chmod +x scripts/gitleaks
rm -rf "$TMP"
echo "Installed scripts/gitleaks (v${VERSION})"
