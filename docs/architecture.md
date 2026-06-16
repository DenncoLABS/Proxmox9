# Proxmox9 architecture notes

## Repository model

This repository is organized as an overlay/customization workspace rather than a direct replacement for Proxmox's official source tree.

## Why not dump everything into one tree?

Proxmox VE is not one single application repository. It is a Debian-based platform assembled from multiple source projects and packages. Copying all upstream files directly into the root of this repo would make updates and patch tracking difficult.

The cleaner model is:

- `upstream/` mirrors official Proxmox projects.
- `apps/` holds standalone Dennco applications.
- `extensions/` holds Proxmox-specific extension work.
- `overlays/` holds patches, branding, and configuration changes.
- `packaging/` turns finished work into installable packages.

## Development rule

Keep original Dennco code separate from upstream Proxmox code. Merge only through documented patches, build scripts, or packages.
