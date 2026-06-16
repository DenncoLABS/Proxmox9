# Signed APT repository notes

The APT repository now builds normal Debian repository metadata:

```text
dists/stable/Release
```

This removes the earlier missing-release warning once the GitHub Pages workflow republishes the site.

The repository can still be used in testing mode with:

```text
deb [trusted=yes] https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel stable main
```

For production, publish a public key file and switch clients to a signed-by source line:

```text
deb [signed-by=/usr/share/keyrings/dennco-proxmox-packages.gpg] https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel stable main
```

Client-side setup shape:

```bash
curl -fsSL https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel/keys/dennco-proxmox-packages.gpg > /usr/share/keyrings/dennco-proxmox-packages.gpg

echo "deb [signed-by=/usr/share/keyrings/dennco-proxmox-packages.gpg] https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel stable main" > /etc/apt/sources.list.d/dennco-novnc-clipboard.list

apt update
apt install dennco-novnc-clipboard-panel
```

Signing requires adding a signing key to the publishing environment and generating:

```text
dists/stable/InRelease
dists/stable/Release.gpg
keys/dennco-proxmox-packages.gpg
```

Do not commit a secret signing key into the repository.
