#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="/usr/share/dennco/novnc-clipboard-panel"
APP_DIR="/usr/share/novnc-pve/app"
LOADER="$APP_DIR/ui.js"
STAMP="dennco-clipboard-panel"
MARK="DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

if [[ ! -f "$SRC_DIR/novnc-clipboard-panel.js" || ! -f "$SRC_DIR/novnc-clipboard-panel.css" ]]; then
  echo "Package files are missing from $SRC_DIR"
  exit 1
fi

if [[ ! -f "$LOADER" ]]; then
  echo "Could not find $LOADER"
  exit 0
fi

mkdir -p "$APP_DIR/dennco-clipboard"
cp "$SRC_DIR/novnc-clipboard-panel.js" "$APP_DIR/dennco-clipboard/novnc-clipboard-panel.js"
cp "$SRC_DIR/novnc-clipboard-panel.css" "$APP_DIR/dennco-clipboard/novnc-clipboard-panel.css"

if [[ ! -f "$LOADER.$STAMP.bak" ]]; then
  cp "$LOADER" "$LOADER.$STAMP.bak"
fi

if ! grep -q "$MARK" "$LOADER"; then
  cat >> "$LOADER" <<'EOF'

/* DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER */
(function () {
  function addAsset(tag, attrs) {
    var el = document.createElement(tag);
    Object.keys(attrs).forEach(function (key) { el.setAttribute(key, attrs[key]); });
    document.head.appendChild(el);
  }
  addAsset('link', { rel: 'stylesheet', href: 'app/dennco-clipboard/novnc-clipboard-panel.css' });
  addAsset('script', { src: 'app/dennco-clipboard/novnc-clipboard-panel.js' });
})();
/* END_DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER */
EOF
fi

systemctl reload pveproxy 2>/dev/null || true

echo "Dennco noVNC clipboard panel repaired for Proxmox 9."
