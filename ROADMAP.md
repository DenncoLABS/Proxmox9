# Roadmap

## Immediate

- Pin the exact Proxmox VE 9 baseline branch/tag for each upstream component.
- Decide first Dennco extension target: dashboard panel, API helper, billing/provisioning agent, or cluster management helper.
- Add first install and rollback script.

## Next

- Add staging node test notes.
- Add package build process for custom work.
- Add smoke tests for web UI/API availability.

## Production rule

Keep upstream source separate. Ship Dennco work as extensions, overlays, or packages whenever possible.
