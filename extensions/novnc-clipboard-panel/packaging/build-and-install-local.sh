#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_FILE="$ROOT_DIR/RELEASE"
VERSION="0.1.1"

if [[ -f "$RELEASE_FILE" ]]; then
  VERSION="$(grep '^release=' "$RELEASE_FILE" | cut -d '=' -f 2 | tr -d '[:space:]')"
fi

DEB="$ROOT_DIR/packaging/dist/dennco-novnc-clipboard-panel_${VERSION}_all.deb"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash packaging/build-and-install-local.sh"
  exit 1
fi

bash "$ROOT_DIR/packaging/build-deb.sh"

dpkg -i "$DEB"

echo "Installed $DEB"
echo "Open the console and refresh the browser."
