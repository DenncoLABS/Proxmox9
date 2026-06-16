#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="/usr/share/novnc/app/dennco-clipboard"
INDEX_FILE="/usr/share/novnc/vnc.html"
BACKUP_FILE="/usr/share/novnc/vnc.html.dennco-clipboard.bak"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "Could not find $INDEX_FILE"
  echo "Check the noVNC path on this Proxmox version before installing."
  exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$SRC_DIR/src/novnc-clipboard-panel.js" "$TARGET_DIR/novnc-clipboard-panel.js"
cp "$SRC_DIR/src/novnc-clipboard-panel.css" "$TARGET_DIR/novnc-clipboard-panel.css"

if [[ ! -f "$BACKUP_FILE" ]]; then
  cp "$INDEX_FILE" "$BACKUP_FILE"
fi

if ! grep -q "dennco-clipboard/novnc-clipboard-panel.js" "$INDEX_FILE"; then
  sed -i 's#</head>#  <link rel="stylesheet" href="dennco-clipboard/novnc-clipboard-panel.css">\n  <script src="dennco-clipboard/novnc-clipboard-panel.js"></script>\n</head>#' "$INDEX_FILE"
fi

echo "Installed noVNC clipboard panel overlay."
echo "Clear browser cache or open a new private window before testing."
