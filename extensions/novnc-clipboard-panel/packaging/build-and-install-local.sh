#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEB="$ROOT_DIR/packaging/dist/dennco-novnc-clipboard-panel_0.1.1_all.deb"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash packaging/build-and-install-local.sh"
  exit 1
fi

bash "$ROOT_DIR/packaging/build-deb.sh"

dpkg -i "$DEB"

echo "Installed $DEB"
echo "Open the console and refresh the browser."
