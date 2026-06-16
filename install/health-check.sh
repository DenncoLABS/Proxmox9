#!/usr/bin/env bash
set -euo pipefail

# Basic repository health check.
# Extend this with platform-specific validation as custom work is added.

echo "Checking repository layout..."

required_dirs=(
  "apps"
  "extensions"
  "overlays"
  "packaging"
  "docs"
  "scripts"
  "install"
  "deploy"
  "tests"
)

for dir in "${required_dirs[@]}"; do
  if [[ ! -d "$dir" ]]; then
    echo "Missing required directory: $dir"
    exit 1
  fi
done

echo "Layout check passed."
