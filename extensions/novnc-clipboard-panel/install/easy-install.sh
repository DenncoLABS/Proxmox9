#!/usr/bin/env bash
set -euo pipefail

EXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JS_SRC="$EXT_DIR/src/novnc-clipboard-panel.js"
CSS_SRC="$EXT_DIR/src/novnc-clipboard-panel.css"
STAMP="dennco-clipboard-panel"
LOADER_MARK="DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash install/easy-install.sh"
  exit 1
fi

if [[ ! -f "$JS_SRC" || ! -f "$CSS_SRC" ]]; then
  echo "Could not find source files. Run this from the checked-out extension folder."
  exit 1
fi

find_js_loader() {
  local candidates=(
    "/usr/share/novnc-pve/app.js"
    "/usr/share/novnc-pve/app/ui.js"
    "/usr/share/novnc-pve/app/webutil.js"
    "/usr/share/novnc/app.js"
    "/usr/share/novnc/app/ui.js"
    "/usr/share/novnc/app/webutil.js"
  )

  for file in "${candidates[@]}"; do
    if [[ -f "$file" ]]; then
      echo "$file"
      return 0
    fi
  done

  while IFS= read -r file; do
    if grep -qi "noVNC\|RFB\|UI" "$file" 2>/dev/null; then
      echo "$file"
      return 0
    fi
  done < <(find /usr/share/novnc-pve /usr/share/novnc -maxdepth 4 -type f -name "*.js" 2>/dev/null)

  return 1
}

install_into_js_loader() {
  local loader_file="$1"
  local base_dir
  local target_dir
  local backup_file
  local asset_prefix

  base_dir="$(dirname "$loader_file")"
  target_dir="$base_dir/dennco-clipboard"
  backup_file="$loader_file.$STAMP.bak"

  asset_prefix="/novnc/dennco-clipboard"
  if [[ "$loader_file" == */app/* ]]; then
    asset_prefix="/novnc/app/dennco-clipboard"
  fi

  mkdir -p "$target_dir"
  cp "$JS_SRC" "$target_dir/novnc-clipboard-panel.js"
  cp "$CSS_SRC" "$target_dir/novnc-clipboard-panel.css"

  if [[ ! -f "$backup_file" ]]; then
    cp "$loader_file" "$backup_file"
  fi

  sed -i '/DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER/,/END_DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER/d' "$loader_file" || true

  cat >> "$loader_file" <<EOF

/* DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER */
(function () {
  function addAsset(tag, attrs) {
    var el = document.createElement(tag);
    Object.keys(attrs).forEach(function (key) { el.setAttribute(key, attrs[key]); });
    document.head.appendChild(el);
  }
  addAsset('link', { rel: 'stylesheet', href: '${asset_prefix}/novnc-clipboard-panel.css' });
  addAsset('script', { src: '${asset_prefix}/novnc-clipboard-panel.js' });
})();
/* END_DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER */
EOF

  echo "Injected loader file: $loader_file"
  echo "Backup file: $backup_file"
  echo "Asset folder: $target_dir"
  echo "Asset URL prefix: $asset_prefix"
}

LOADER_FILE="$(find_js_loader || true)"
if [[ -z "${LOADER_FILE:-}" ]]; then
  echo "Could not find noVNC JavaScript loader automatically."
  echo "Run: find /usr/share/novnc-pve -type f -name '*.js' | sort"
  exit 1
fi

install_into_js_loader "$LOADER_FILE"

systemctl reload pveproxy 2>/dev/null || true

echo "Installed Dennco noVNC clipboard panel."
echo "Open the console in a private window or hard refresh the browser."
