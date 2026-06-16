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
DIST_ROOT="$REPO_ROOT/dists/stable"
DIST_ALL_DIR="$DIST_ROOT/main/binary-all"
DIST_AMD64_DIR="$DIST_ROOT/main/binary-amd64"
DEB_FILE="$ROOT_DIR/packaging/dist/${PKG_NAME}_${VERSION}_all.deb"

bash "$ROOT_DIR/packaging/build-deb.sh"

rm -rf "$REPO_ROOT"
mkdir -p "$POOL_DIR" "$DIST_ALL_DIR" "$DIST_AMD64_DIR"
cp "$DEB_FILE" "$POOL_DIR/"

cd "$REPO_ROOT"
if command -v apt-ftparchive >/dev/null 2>&1; then
  apt-ftparchive packages pool > "$DIST_ALL_DIR/Packages"
else
  dpkg-scanpackages pool /dev/null > "$DIST_ALL_DIR/Packages"
fi

cp "$DIST_ALL_DIR/Packages" "$DIST_AMD64_DIR/Packages"
gzip -kf "$DIST_ALL_DIR/Packages"
gzip -kf "$DIST_AMD64_DIR/Packages"

RELEASE_TMP="$DIST_ROOT/Release.generated"
if command -v apt-ftparchive >/dev/null 2>&1; then
  apt-ftparchive release "$DIST_ROOT" > "$RELEASE_TMP"
else
  : > "$RELEASE_TMP"
fi

cat > "$DIST_ROOT/Release" <<EOF
Origin: Dennco
Label: Dennco Proxmox Packages
Suite: stable
Codename: stable
Version: ${VERSION}
Architectures: amd64 all
Components: main
Description: Dennco Proxmox package repository
EOF

if [[ -s "$RELEASE_TMP" ]]; then
  grep -Ev '^(Origin|Label|Suite|Codename|Version|Architectures|Components|Description):' "$RELEASE_TMP" >> "$DIST_ROOT/Release"
fi
rm -f "$RELEASE_TMP"

if [[ "${SIGN_APT_REPO:-0}" == "1" ]]; then
  gpg --batch --yes --armor --detach-sign --output "$DIST_ROOT/Release.gpg" "$DIST_ROOT/Release"
  gpg --batch --yes --clearsign --output "$DIST_ROOT/InRelease" "$DIST_ROOT/Release"
fi

cat > "$REPO_ROOT/README.txt" <<EOF
Dennco APT repository for the Proxmox noVNC clipboard panel.

Package: ${PKG_NAME}
Version: ${VERSION}

Testing source line:
deb [trusted=yes] REPLACE_WITH_REPO_URL stable main

Signed source line:
deb [signed-by=/usr/share/keyrings/dennco-proxmox-packages.gpg] REPLACE_WITH_REPO_URL stable main
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
<pre>deb [signed-by=/usr/share/keyrings/dennco-proxmox-packages.gpg] REPLACE_WITH_REPO_URL stable main</pre>
</body>
</html>
EOF

echo "APT repo built at: $REPO_ROOT"
echo "Package version: $VERSION"
