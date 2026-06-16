#!/usr/bin/env bash
set -euo pipefail

# Clone or update Proxmox upstream source repositories.
# Run from the repository root:
#   bash scripts/sync-upstream.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM_DIR="$ROOT_DIR/upstream"
mkdir -p "$UPSTREAM_DIR"

# Proxmox publishes source at git.proxmox.com. The exact Proxmox VE 9 branch/tag
# can vary per component, so this script mirrors default branches by default.
# Pin specific branches/tags later when you decide the exact PVE 9 baseline.
repos=(
  "pve-manager.git"
  "pve-docs.git"
  "pve-common.git"
  "pve-cluster.git"
  "pve-access-control.git"
  "pve-storage.git"
  "pve-container.git"
  "qemu-server.git"
  "pve-firewall.git"
  "pve-ha-manager.git"
  "pve-guest-common.git"
  "pve-http-server.git"
  "pve-widget-toolkit.git"
  "proxmox-widget-toolkit.git"
  "proxmox-backup.git"
  "proxmox.git"
)

cd "$UPSTREAM_DIR"

for repo in "${repos[@]}"; do
  name="${repo%.git}"
  url="https://git.proxmox.com/git/$repo"

  if [[ -d "$name/.git" ]]; then
    echo "Updating $name"
    git -C "$name" fetch --all --tags --prune
  else
    echo "Cloning $url"
    git clone "$url" "$name"
  fi
done

echo "Done. Upstream repositories are in: $UPSTREAM_DIR"
