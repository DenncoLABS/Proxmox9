#!/usr/bin/env bash
set -euo pipefail

STAMP="dennco-clipboard-panel"
LOADER_MARK="DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash install/easy-uninstall.sh"
  exit 1
fi

find_installed_loader() {
  while IFS= read -r file; do
    if grep -q "$LOADER_MARK" "$file" 2>/dev/null; then
      echo "$file"
      return 0
    fi
  done < <(find /usr/share/novnc-pve /usr/share/novnc -maxdepth 5 -type f -name "*.js" 2>/dev/null)

  return 1
}

restore_file() {
  local file="$1"
  local backup="$file.$STAMP.bak"
  local dir
  dir="$(dirname "$file")"

  if [[ -f "$backup" ]]; then
    cp "$backup" "$file"
    rm -f "$backup"
  else
    sed -i '/DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER/,/END_DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER/d' "$file" || true
  fi

  rm -rf "$dir/dennco-clipboard"
  rm -rf "$dir/app/dennco-clipboard"
  echo "Updated file: $file"
}

LOADER_FILE="$(find_installed_loader || true)"

if [[ -n "${LOADER_FILE:-}" ]]; then
  restore_file "$LOADER_FILE"
else
  echo "Could not find an injected noVNC loader file. Nothing to remove."
  exit 0
fi

systemctl reload pveproxy 2>/dev/null || true

echo "Removed Dennco noVNC clipboard panel."
