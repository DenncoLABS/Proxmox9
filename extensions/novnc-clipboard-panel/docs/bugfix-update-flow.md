# Bugfix update flow

The package is designed to repair itself during upgrades.

When a newer package version is installed with `apt upgrade`, Debian runs the package post-install script. That script calls:

```bash
/usr/sbin/dennco-novnc-clipboard-repair
```

The repair command:

- Finds the local noVNC HTML file.
- Re-copies the newest JavaScript and CSS files.
- Re-adds the script and stylesheet tags if Proxmox updates removed them.
- Reloads `pveproxy` when available.

## After fixing a bug

1. Edit the source files.
2. Bump the package version.
3. Rebuild the deb package.
4. Rebuild the APT repo files.
5. Publish the updated repo files.
6. Run `apt update && apt upgrade` on the Proxmox host.

## Manual repair

If needed, run:

```bash
sudo dennco-novnc-clipboard-repair
```

This reapplies the overlay without reinstalling the package.

## Important

APT only upgrades when the package version increases. Bugfix releases must use a newer version number, such as:

```text
0.1.1
0.1.2
0.2.0
```
