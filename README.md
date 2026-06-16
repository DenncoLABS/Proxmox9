# Proxmox9

Private Dennco workspace for Proxmox VE 9 research, customization, packaging, and extension development.

## Purpose

This repository is **not** intended to replace Proxmox's official upstream Git repositories. Proxmox VE is built from multiple source projects and Debian packages. This repo is organized as a working overlay where upstream source can be mirrored into `upstream/`, while custom Dennco work lives separately under `apps/`, `extensions/`, `overlays/`, and `packaging/`.

## Recommended layout

```text
Proxmox9/
├── upstream/              # Local mirrors/checkouts of official Proxmox source repos
├── apps/                  # Standalone apps you build around Proxmox
├── extensions/            # Proxmox UI/API/plugin-style extensions
├── overlays/              # Patches, branding, config overlays, service overrides
├── packaging/             # Debian packaging, build scripts, release notes
├── docs/                  # Architecture notes and operating procedures
├── scripts/               # Helper scripts for cloning, syncing, and building
└── .github/workflows/     # Optional CI workflows
```

## Should apps/extensions be separate repos?

Use this repo for early development and related experiments. Move mature apps/extensions into separate repos when they have their own release cycle, issue tracker, package name, or customer-facing documentation.

Recommended rule:

- Keep **small patches, scripts, experiments, and Proxmox-specific overlays** in this repo.
- Put **production apps, reusable extensions, commercial modules, or anything with its own versioning** in a separate repo.

## Upstream source

Use `scripts/sync-upstream.sh` to clone official upstream Proxmox repositories into `upstream/`. This keeps your custom work separate from upstream source and makes future syncing cleaner.

