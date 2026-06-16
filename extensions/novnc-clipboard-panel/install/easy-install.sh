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

find_js_loader() {
  local candidates=(
    "/usr/share/novnc-pve/app/ui.js"
    "/usr/share/novnc-pve/app/webutil.js"
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

install_into_html() {
  local html_file="$1"
  local html_dir
  local target_dir
  local backup_file

  html_dir="$(dirname "$html_file")"
  target_dir="$html_dir/dennco-clipboard"
  backup_file="$html_file.$STAMP.bak"

  mkdir -p "$target_dir"
  cp "$JS_SRC" "$target_dir/novnc-clipboard-panel.js"
  cp "$CSS_SRC" "$target_dir/novnc-clipboard-panel.css"

  if [[ ! -f "$backup_file" ]]; then
    cp "$html_file" "$backup_file"
  fi

  if grep -q "dennco-clipboard/novnc-clipboard-panel.js" "$html_file"; then
    echo "Clipboard panel is already injected in $html_file"
  else
    if grep -q "</head>" "$html_file"; then
      sed -i 's#</head>#  <link rel="stylesheet" href="dennco-clipboard/novnc-clipboard-panel.css">\n  <script src="dennco-clipboard/novnc-clipboard-panel.js"></script>\n</head>#' "$html_file"
    else
      echo "Could not find </head> in $html_file"
      echo "Backup remains at $backup_file"
      exit 1
    fi
  fi

  echo "Injected HTML file: $html_file"
  echo "Backup file: $backup_file"
}

install_into_js_loader() {
  local loader_file="$1"
  local app_dir
  local target_dir
  local backup_file

  app_dir="$(dirname "$loader_file")"
  target_dir="$app_dir/dennco-clipboard"
  backup_file="$loader_file.$STAMP.bak"

  mkdir -p "$target_dir"
  cp "$JS_SRC" "$target_dir/novnc-clipboard-panel.js"
  cp "$CSS_SRC" "$target_dir/novnc-clipboard-panel.css"

  if [[ ! -f "$backup_file" ]]; then
    cp "$loader_file" "$backup_file"
  fi

  if grep -q "$LOADER_MARK" "$loader_file"; then
    echo "Clipboard loader is already injected in $loader_file"
  else
    cat >> "$loader_file" <<'EOF'

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

  echo "Injected loader file: $loader_file"
  echo "Backup file: $backup_file"
}

HTML_FILE="$(find_html || true)"
if [[ -n "${HTML_FILE:-}" ]]; then
  install_into_html "$HTML_FILE"
else
  LOADER_FILE="$(find_js_loader || true)"
  if [[ -z "${LOADER_FILE:-}" ]]; then
    echo "Could not find noVNC HTML or JavaScript loader automatically."
    echo "Run: find /usr/share/novnc-pve -type f | head -50"
    exit 1
  fi
  install_into_js_loader "$LOADER_FILE"
fi

systemctl reload pveproxy 2>/dev/null || true

echo "Installed Dennco noVNC clipboard panel."
echo "Open the console in a private window or hard refresh the browser."
