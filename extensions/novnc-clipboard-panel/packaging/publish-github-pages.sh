#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$ROOT_DIR/packaging/apt-repo"
PROJECT_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
PUBLISH_DIR="$PROJECT_ROOT/docs/novnc-clipboard-panel"

bash "$ROOT_DIR/packaging/build-apt-repo.sh"

rm -rf "$PUBLISH_DIR"
mkdir -p "$PUBLISH_DIR"
cp -a "$REPO_ROOT/." "$PUBLISH_DIR/"

echo "Published APT repo files to: $PUBLISH_DIR"
echo "Commit and push the docs/novnc-clipboard-panel folder, then enable GitHub Pages from /docs on main."
