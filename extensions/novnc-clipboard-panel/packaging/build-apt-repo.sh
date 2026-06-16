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
REPO_URL="https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel"
KEYRING_PATH="/usr/share/keyrings/dennco-proxmox-packages.gpg"
SOURCE_PATH="/etc/apt/sources.list.d/dennco-novnc-clipboard.list"

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

cat > "$REPO_ROOT/install.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail

if [[ "\$(id -u)" -ne 0 ]]; then
  echo "Run this installer as root." >&2
  exit 1
fi

if [[ ! -d /etc/pve && ! -d /usr/share/novnc-pve ]]; then
  echo "Warning: this does not look like a Proxmox VE host." >&2
fi

if ! command -v curl >/dev/null 2>&1; then
  apt-get update
  apt-get install -y curl
fi

mkdir -p /usr/share/keyrings
curl -fsSL "${REPO_URL}/keys/dennco-proxmox-packages.gpg" > "${KEYRING_PATH}"
chmod 0644 "${KEYRING_PATH}"

cat > "${SOURCE_PATH}" <<'SRC'
deb [signed-by=${KEYRING_PATH}] ${REPO_URL} stable main
SRC

apt-get update
apt-get install -y ${PKG_NAME}

echo "Dennco noVNC clipboard panel install complete."
EOF
chmod 0755 "$REPO_ROOT/install.sh"

cat > "$REPO_ROOT/README.txt" <<EOF
Dennco APT repository for the Proxmox noVNC clipboard panel.

Package: ${PKG_NAME}
Version: ${VERSION}

One-line install:
curl -fsSL ${REPO_URL}/install.sh | bash

Signed source line:
deb [signed-by=${KEYRING_PATH}] ${REPO_URL} stable main
EOF

cat > "$REPO_ROOT/index.html" <<EOF
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Dennco Proxmox noVNC Clipboard APT Repo</title></head>
<body>
<h1>Dennco Proxmox noVNC Clipboard APT Repo</h1>
<p>Package: ${PKG_NAME}</p>
<p>Version: ${VERSION}</p>
<h2>Install</h2>
<pre>curl -fsSL ${REPO_URL}/install.sh | bash</pre>
<h2>Signed source</h2>
<pre>deb [signed-by=${KEYRING_PATH}] ${REPO_URL} stable main</pre>
</body>
</html>
EOF

echo "APT repo built at: $REPO_ROOT"
echo "Package version: $VERSION"
