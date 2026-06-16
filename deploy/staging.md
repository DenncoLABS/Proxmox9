# Staging deployment

Use staging before applying any custom Proxmox9 extension, overlay, or package to production.

## Checklist

1. Sync upstream source locally if needed.
2. Apply extension or overlay in a test environment.
3. Run `bash install/health-check.sh`.
4. Confirm services restart cleanly.
5. Confirm web UI/API access.
6. Record rollback steps.

## Notes

Document staging hostnames, test results, and known issues here. Do not store passwords or secrets.
