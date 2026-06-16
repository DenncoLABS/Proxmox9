# Extensions

Use this folder for Proxmox-specific extensions, UI changes, API additions, and plugin-style modules.

Examples:

- Web UI panels
- Custom ExtJS components
- API endpoint additions
- Node management helpers
- Storage/networking helpers
- Dennco branding or workflow extensions

## Recommended extension structure

```text
extensions/
└── example-extension/
    ├── README.md
    ├── src/
    ├── patches/
    ├── packaging/
    └── tests/
```

Keep upstream Proxmox source out of this folder. Put source mirrors in `upstream/` and keep your original extension work here.
