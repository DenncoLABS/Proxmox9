# Packaging

Use this folder for Debian packaging, build scripts, version notes, and release automation for Proxmox-related custom work.

Examples:

- `.deb` package metadata
- Build scripts
- Changelog files
- Version pinning notes
- Apt repository publishing scripts

Recommended approach:

- Package apps/extensions separately when they are production-ready.
- Keep Proxmox upstream package changes as patches instead of permanent edits where possible.
- Document dependency and version assumptions clearly.
