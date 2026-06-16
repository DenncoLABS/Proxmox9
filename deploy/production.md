# Production deployment

Production changes must be treated as controlled releases.

## Release checklist

1. Confirm change was tested in staging.
2. Confirm rollback method exists.
3. Confirm backups or snapshots exist.
4. Confirm maintenance window if service impact is possible.
5. Deploy only reviewed extensions, overlays, or packages.
6. Run `bash install/health-check.sh` after deployment.
7. Record version, date, and result.

## Rollback

Document exact rollback commands and affected services before deploying.

Do not store secrets in this file.
