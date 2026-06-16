# GitHub Pages APT repository

The Proxmox noVNC clipboard package can be published through GitHub Pages.

Expected public URL:

```text
https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel
```

The published folder should contain:

```text
dists/stable/main/binary-all/Packages
dists/stable/main/binary-all/Packages.gz
pool/main/d/dennco-novnc-clipboard-panel/dennco-novnc-clipboard-panel_0.1.1_all.deb
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

Then add the source on Proxmox by creating this file:

```text
/etc/apt/sources.list.d/dennco-novnc-clipboard.list
```

with this line:

```text
deb [trusted=yes] https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel stable main
```

Then run:

```bash
apt update
apt install dennco-novnc-clipboard-panel
```

Use trusted mode only for early testing. For production, sign the repository and install the public key instead.
