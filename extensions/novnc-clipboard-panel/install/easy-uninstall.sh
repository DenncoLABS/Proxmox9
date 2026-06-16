#!/usr/bin/env bash
set -euo pipefail

STAMP="dennco-clipboard-panel"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash install/easy-uninstall.sh"
  exit 1
fi

find_installed_html() {
  while IFS= read -r file; do
    if grep -q "dennco-clipboard/novnc-clipboard-panel.js" "$file" 2>/dev/null; then
      echo "$file"
      return 0
    fi
  done < <(find /usr/share -maxdepth 5 -type f \( -name "vnc.html" -o -name "index.html" \) 2>/dev/null)

  return 1
}

HTML_FILE="$(find_installed_html || true)"

if [[ -z "${HTML_FILE:-}" ]]; then
  echo "Could not find an injected noVNC HTML file. Nothing to remove."
  exit 0
fi

HTML_DIR="$(dirname "$HTML_FILE")"
TARGET_DIR="$HTML_DIR/dennco-clipboard"
BACKUP_FILE="$HTML_FILE.$STAMP.bak"

if [[ -f "$BACKUP_FILE" ]]; then
  cp "$BACKUP_FILE" "$HTML_FILE"
  rm -f "$BACKUP_FILE"
else
  sed -i '/dennco-clipboard\/novnc-clipboard-panel.css/d' "$HTML_FILE" || true
  sed -i '/dennco-clipboard\/novnc-clipboard-panel.js/d' "$HTML_FILE" || true
fi

rm -rf "$TARGET_DIR"
systemctl reload pveproxy 2>/dev/null || true

echo "Removed Dennco noVNC clipboard panel."
echo "Updated file: $HTML_FILE"
