#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_NAME="dennco-novnc-clipboard-panel"
VERSION="0.1.0"
BUILD_ROOT="$ROOT_DIR/packaging/build"
PKG_ROOT="$BUILD_ROOT/${PKG_NAME}_${VERSION}_all"
OUT_DIR="$ROOT_DIR/packaging/dist"

rm -rf "$BUILD_ROOT"
mkdir -p "$PKG_ROOT/DEBIAN"
mkdir -p "$PKG_ROOT/usr/share/dennco/novnc-clipboard-panel"
mkdir -p "$PKG_ROOT/usr/sbin"
mkdir -p "$OUT_DIR"

cp "$ROOT_DIR/packaging/debian/control" "$PKG_ROOT/DEBIAN/control"
cp "$ROOT_DIR/packaging/debian/postinst" "$PKG_ROOT/DEBIAN/postinst"
cp "$ROOT_DIR/packaging/debian/prerm" "$PKG_ROOT/DEBIAN/prerm"
chmod 0755 "$PKG_ROOT/DEBIAN/postinst" "$PKG_ROOT/DEBIAN/prerm"

cp "$ROOT_DIR/src/novnc-clipboard-panel.js" "$PKG_ROOT/usr/share/dennco/novnc-clipboard-panel/novnc-clipboard-panel.js"
cp "$ROOT_DIR/src/novnc-clipboard-panel.css" "$PKG_ROOT/usr/share/dennco/novnc-clipboard-panel/novnc-clipboard-panel.css"
cp "$ROOT_DIR/install/repair.sh" "$PKG_ROOT/usr/sbin/dennco-novnc-clipboard-repair"
chmod 0755 "$PKG_ROOT/usr/sbin/dennco-novnc-clipboard-repair"

dpkg-deb --build "$PKG_ROOT" "$OUT_DIR/${PKG_NAME}_${VERSION}_all.deb"

echo "Built package: $OUT_DIR/${PKG_NAME}_${VERSION}_all.deb"
