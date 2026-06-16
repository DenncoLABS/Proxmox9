#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="/usr/share/novnc/app/dennco-clipboard"
INDEX_FILE="/usr/share/novnc/vnc.html"
BACKUP_FILE="/usr/share/novnc/vnc.html.dennco-clipboard.bak"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

if [[ -f "$BACKUP_FILE" ]]; then
  cp "$BACKUP_FILE" "$INDEX_FILE"
  rm -f "$BACKUP_FILE"
else
  if [[ -f "$INDEX_FILE" ]]; then
    sed -i '/dennco-clipboard\/novnc-clipboard-panel.css/d' "$INDEX_FILE"
    sed -i '/dennco-clipboard\/novnc-clipboard-panel.js/d' "$INDEX_FILE"
  fi
fi

rm -rf "$TARGET_DIR"

echo "Removed noVNC clipboard panel overlay."
