# Upstream Proxmox source

This folder is for local checkouts or mirrors of official Proxmox source repositories.

Do not edit upstream source directly unless you are intentionally maintaining a fork. Prefer this pattern:

1. Clone or sync upstream source into `upstream/`.
2. Keep Dennco patches in `overlays/` or `extensions/`.
3. Apply patches during build or packaging.
4. Keep notes in `docs/` explaining why each change exists.

This keeps the repo maintainable when Proxmox releases updates.

## Sync command

From the repo root:

```bash
bash scripts/sync-upstream.sh
```
