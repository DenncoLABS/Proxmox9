#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$ROOT_DIR/packaging/apt-repo"
DIST_DIR="$REPO_ROOT/dists/stable/main/binary-all"
DEB_FILE="$ROOT_DIR/packaging/dist/dennco-novnc-clipboard-panel_0.1.0_all.deb"

bash "$ROOT_DIR/packaging/build-deb.sh"

rm -rf "$REPO_ROOT"
mkdir -p "$DIST_DIR"
cp "$DEB_FILE" "$DIST_DIR/"

cd "$DIST_DIR"
if command -v apt-ftparchive >/dev/null 2>&1; then
  apt-ftparchive packages . > Packages
else
  dpkg-scanpackages . /dev/null > Packages
fi

gzip -kf Packages

cat > "$REPO_ROOT/README.txt" <<'EOF'
Dennco APT repository for the Proxmox noVNC clipboard panel.

Example source line:
deb [trusted=yes] REPLACE_WITH_REPO_URL stable main
EOF

echo "APT repo built at: $REPO_ROOT"
