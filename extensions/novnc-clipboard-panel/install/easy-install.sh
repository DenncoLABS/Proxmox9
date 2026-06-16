#!/usr/bin/env bash
set -euo pipefail

EXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JS_SRC="$EXT_DIR/src/novnc-clipboard-panel.js"
CSS_SRC="$EXT_DIR/src/novnc-clipboard-panel.css"
STAMP="dennco-clipboard-panel"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash install/easy-install.sh"
  exit 1
fi

if [[ ! -f "$JS_SRC" || ! -f "$CSS_SRC" ]]; then
  echo "Could not find source files. Run this from the checked-out extension folder."
  exit 1
fi

find_html() {
  local candidates=(
    "/usr/share/novnc/vnc.html"
    "/usr/share/novnc/index.html"
    "/usr/share/novnc-pve/vnc.html"
    "/usr/share/novnc-pve/index.html"
  )

  for file in "${candidates[@]}"; do
    if [[ -f "$file" ]]; then
      echo "$file"
      return 0
    fi
  done

  while IFS= read -r file; do
    if grep -qi "novnc\|noVNC" "$file" 2>/dev/null; then
      echo "$file"
      return 0
    fi
  done < <(find /usr/share -maxdepth 5 -type f \( -name "vnc.html" -o -name "index.html" \) 2>/dev/null)

  return 1
}

HTML_FILE="$(find_html || true)"

if [[ -z "${HTML_FILE:-}" ]]; then
  echo "Could not find the noVNC HTML file automatically."
  echo "Run: find /usr/share -iname 'vnc.html' -o -iname '*novnc*'"
  exit 1
fi

HTML_DIR="$(dirname "$HTML_FILE")"
TARGET_DIR="$HTML_DIR/dennco-clipboard"
BACKUP_FILE="$HTML_FILE.$STAMP.bak"

mkdir -p "$TARGET_DIR"
cp "$JS_SRC" "$TARGET_DIR/novnc-clipboard-panel.js"
cp "$CSS_SRC" "$TARGET_DIR/novnc-clipboard-panel.css"

if [[ ! -f "$BACKUP_FILE" ]]; then
  cp "$HTML_FILE" "$BACKUP_FILE"
fi

if grep -q "dennco-clipboard/novnc-clipboard-panel.js" "$HTML_FILE"; then
  echo "Clipboard panel is already injected in $HTML_FILE"
else
  if grep -q "</head>" "$HTML_FILE"; then
    sed -i 's#</head>#  <link rel="stylesheet" href="dennco-clipboard/novnc-clipboard-panel.css">\n  <script src="dennco-clipboard/novnc-clipboard-panel.js"></script>\n</head>#' "$HTML_FILE"
  else
    echo "Could not find </head> in $HTML_FILE"
    echo "Backup remains at $BACKUP_FILE"
    exit 1
  fi
fi

systemctl reload pveproxy 2>/dev/null || true

echo "Installed Dennco noVNC clipboard panel."
echo "Injected file: $HTML_FILE"
echo "Backup file: $BACKUP_FILE"
echo "Open the console in a private window or hard refresh the browser."
