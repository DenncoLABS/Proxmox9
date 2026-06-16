# Signed APT repository notes

The APT repository builds normal Debian repository metadata:

```text
dists/stable/Release
dists/stable/InRelease
dists/stable/Release.gpg
```

Clients should use the signed repository with a local keyring file.

## Production source line

```text
deb [signed-by=/usr/share/keyrings/dennco-proxmox-packages.gpg] https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel stable main
```

## One-line install

```bash
curl -fsSL https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel/install.sh | bash
```

## Manual client-side setup

```bash
curl -fsSL https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel/keys/dennco-proxmox-packages.gpg > /usr/share/keyrings/dennco-proxmox-packages.gpg

echo "deb [signed-by=/usr/share/keyrings/dennco-proxmox-packages.gpg] https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel stable main" > /etc/apt/sources.list.d/dennco-novnc-clipboard.list

apt update
apt install dennco-novnc-clipboard-panel
```

## Published signing files

Signing requires adding a private signing key to the GitHub Actions environment as a repository secret named:

```text
APT_GPG_PRIVATE_KEY
```

The workflow publishes:

```text
dists/stable/InRelease
dists/stable/Release.gpg
keys/dennco-proxmox-packages.gpg
keys/dennco-proxmox-packages.asc
```

The private signing key must not be committed to the repository. Proxmox clients only receive the public key.
