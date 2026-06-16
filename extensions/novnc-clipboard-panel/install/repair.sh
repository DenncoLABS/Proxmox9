#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="/usr/share/dennco/novnc-clipboard-panel"
STAMP="dennco-clipboard-panel"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root."
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

if [[ ! -f "$PACKAGE_DIR/novnc-clipboard-panel.js" || ! -f "$PACKAGE_DIR/novnc-clipboard-panel.css" ]]; then
  echo "Package files missing from $PACKAGE_DIR"
  exit 1
fi

HTML_FILE="$(find_html || true)"
if [[ -z "${HTML_FILE:-}" ]]; then
  echo "Could not find noVNC HTML file. Repair skipped."
  exit 0
fi

HTML_DIR="$(dirname "$HTML_FILE")"
TARGET_DIR="$HTML_DIR/dennco-clipboard"
BACKUP_FILE="$HTML_FILE.$STAMP.bak"

mkdir -p "$TARGET_DIR"
cp "$PACKAGE_DIR/novnc-clipboard-panel.js" "$TARGET_DIR/novnc-clipboard-panel.js"
cp "$PACKAGE_DIR/novnc-clipboard-panel.css" "$TARGET_DIR/novnc-clipboard-panel.css"

if [[ ! -f "$BACKUP_FILE" ]]; then
  cp "$HTML_FILE" "$BACKUP_FILE"
fi

if ! grep -q "dennco-clipboard/novnc-clipboard-panel.js" "$HTML_FILE"; then
  if grep -q "</head>" "$HTML_FILE"; then
    sed -i 's#</head>#  <link rel="stylesheet" href="dennco-clipboard/novnc-clipboard-panel.css">\n  <script src="dennco-clipboard/novnc-clipboard-panel.js"></script>\n</head>#' "$HTML_FILE"
  else
    echo "Could not find </head> in $HTML_FILE"
    exit 1
  fi
fi

systemctl reload pveproxy 2>/dev/null || true

echo "Dennco noVNC clipboard panel repaired."
echo "HTML file: $HTML_FILE"
