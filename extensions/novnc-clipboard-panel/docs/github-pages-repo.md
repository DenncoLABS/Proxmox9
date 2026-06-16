# GitHub Pages APT repository

The Proxmox noVNC clipboard package can be published through GitHub Pages.

Expected public URL:

```text
https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel
```

The published folder should contain:

```text
dists/stable/InRelease
dists/stable/Release
dists/stable/Release.gpg
dists/stable/main/binary-all/Packages
dists/stable/main/binary-all/Packages.gz
dists/stable/main/binary-amd64/Packages
dists/stable/main/binary-amd64/Packages.gz
pool/main/d/dennco-novnc-clipboard-panel/dennco-novnc-clipboard-panel_0.1.2_all.deb
keys/dennco-proxmox-packages.gpg
keys/dennco-proxmox-packages.asc
install.sh
README.txt
index.html
```

Build and stage the GitHub Pages folder with:

```bash
cd ~/Proxmox9/extensions/novnc-clipboard-panel
bash packaging/publish-github-pages.sh
```

That script builds the Debian package, builds the APT metadata, and copies the generated repository into:

```text
docs/novnc-clipboard-panel/
```

Commit and push the generated files:

```bash
cd ~/Proxmox9
git add docs/novnc-clipboard-panel extensions/novnc-clipboard-panel
git commit -m "Publish noVNC clipboard APT repository"
git push
```

In GitHub, enable Pages for this repository using:

```text
Source: Deploy from a branch
Branch: main
Folder: /docs
```

## One-line install

On a Proxmox host:

```bash
curl -fsSL https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel/install.sh | bash
```

## Manual signed source

Add the key:

```bash
curl -fsSL https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel/keys/dennco-proxmox-packages.gpg > /usr/share/keyrings/dennco-proxmox-packages.gpg
```

Then create:

```text
/etc/apt/sources.list.d/dennco-novnc-clipboard.list
```

with this line:

```text
deb [signed-by=/usr/share/keyrings/dennco-proxmox-packages.gpg] https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel stable main
```

Then run:

```bash
apt update
apt install dennco-novnc-clipboard-panel
```

Do not use trusted mode for production. Use the signed repository and public key instead.
