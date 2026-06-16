#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="/usr/share/dennco/novnc-clipboard-panel"
APP_ROOT="/usr/share/novnc-pve"
LOADER="$APP_ROOT/app.js"
STAMP="dennco-clipboard-panel"
MARK="DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER"
EXT_VERSION="0.1.1"

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

mkdir -p "$APP_ROOT/dennco-clipboard"
cp "$SRC_DIR/novnc-clipboard-panel.js" "$APP_ROOT/dennco-clipboard/novnc-clipboard-panel.js"
cp "$SRC_DIR/novnc-clipboard-panel.css" "$APP_ROOT/dennco-clipboard/novnc-clipboard-panel.css"

if [[ ! -f "$LOADER.$STAMP.bak" ]]; then
  cp "$LOADER" "$LOADER.$STAMP.bak"
fi

sed -i '/DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER/,/END_DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER/d' "$LOADER" || true

cat >> "$LOADER" <<EOF

/* DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER */
(function () {
  function addAsset(tag, attrs) {
    var el = document.createElement(tag);
    Object.keys(attrs).forEach(function (key) { el.setAttribute(key, attrs[key]); });
    document.head.appendChild(el);
  }
  addAsset('link', { rel: 'stylesheet', href: '/novnc/dennco-clipboard/novnc-clipboard-panel.css?v=${EXT_VERSION}' });
  addAsset('script', { src: '/novnc/dennco-clipboard/novnc-clipboard-panel.js?v=${EXT_VERSION}' });
})();
/* END_DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER */
EOF

systemctl reload pveproxy 2>/dev/null || true

echo "Dennco noVNC clipboard panel repaired for Proxmox 9."
echo "Extension version: $EXT_VERSION"
