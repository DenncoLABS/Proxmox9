# Overlays

Use this folder for changes that should be applied on top of upstream Proxmox source or installed packages.

Examples:

- Branding changes
- Configuration templates
- Systemd service overrides
- UI patches
- API patches
- Build-time patch files

Suggested structure:

```text
overlays/
├── branding/
├── config/
├── patches/
└── systemd/
```

Avoid editing upstream source directly when an overlay or patch will do the job.
