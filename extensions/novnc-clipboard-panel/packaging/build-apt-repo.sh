#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_FILE="$ROOT_DIR/RELEASE"
PKG_NAME="dennco-novnc-clipboard-panel"
VERSION="0.1.1"

if [[ -f "$RELEASE_FILE" ]]; then
  VERSION="$(grep '^release=' "$RELEASE_FILE" | cut -d '=' -f 2 | tr -d '[:space:]')"
fi

REPO_ROOT="$ROOT_DIR/packaging/apt-repo"
POOL_DIR="$REPO_ROOT/pool/main/d/dennco-novnc-clipboard-panel"
DIST_DIR="$REPO_ROOT/dists/stable/main/binary-all"
DEB_FILE="$ROOT_DIR/packaging/dist/${PKG_NAME}_${VERSION}_all.deb"

bash "$ROOT_DIR/packaging/build-deb.sh"

rm -rf "$REPO_ROOT"
mkdir -p "$POOL_DIR" "$DIST_DIR"
cp "$DEB_FILE" "$POOL_DIR/"

cd "$REPO_ROOT"
if command -v apt-ftparchive >/dev/null 2>&1; then
  apt-ftparchive packages pool > "$DIST_DIR/Packages"
else
  dpkg-scanpackages pool /dev/null > "$DIST_DIR/Packages"
fi

gzip -kf "$DIST_DIR/Packages"

cat > "$REPO_ROOT/README.txt" <<EOF
Dennco APT repository for the Proxmox noVNC clipboard panel.

Package: ${PKG_NAME}
Version: ${VERSION}

Example source line:
deb [trusted=yes] REPLACE_WITH_REPO_URL stable main
EOF

cat > "$REPO_ROOT/index.html" <<EOF
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Dennco Proxmox noVNC Clipboard APT Repo</title></head>
<body>
<h1>Dennco Proxmox noVNC Clipboard APT Repo</h1>
<p>Package: ${PKG_NAME}</p>
<p>Version: ${VERSION}</p>
<pre>deb [trusted=yes] REPLACE_WITH_REPO_URL stable main</pre>
</body>
</html>
EOF

echo "APT repo built at: $REPO_ROOT"
echo "Package version: $VERSION"
