# noVNC Clipboard Panel

Browser-side clipboard panel for the Proxmox noVNC console.

The extension adds a clipboard button to the Proxmox noVNC side control bar. The button opens a small textarea panel where text can be pasted in the browser and sent into the active console as typed keystrokes.

This is not true guest clipboard synchronization. It is paste-as-keystrokes for Proxmox browser consoles.

## Current status

```text
Package: dennco-novnc-clipboard-panel
Version: 0.1.2 beta
Target: Proxmox VE 9.x / noVNC console
Install method: signed APT repo hosted on GitHub Pages
Update method: apt update && apt upgrade
```

Test on a non-production Proxmox node before broad deployment.

## One-line install

Run as root on a Proxmox host:

```bash
curl -fsSL https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel/install.sh | bash
```

The installer automatically:

1. Downloads the Dennco public APT signing key.
2. Installs the key at `/usr/share/keyrings/dennco-proxmox-packages.gpg`.
3. Adds the signed APT source file at `/etc/apt/sources.list.d/dennco-novnc-clipboard.list`.
4. Runs `apt update`.
5. Installs `dennco-novnc-clipboard-panel`.
6. Repairs/reinjects the noVNC loader through the package post-install script.

After install, open a VM console in a private browser window or hard-refresh the noVNC page.

## Manual signed APT setup

For administrators who prefer to configure the repo manually:

```bash
curl -fsSL https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel/keys/dennco-proxmox-packages.gpg > /usr/share/keyrings/dennco-proxmox-packages.gpg

cat > /etc/apt/sources.list.d/dennco-novnc-clipboard.list <<'EOF'
deb [signed-by=/usr/share/keyrings/dennco-proxmox-packages.gpg] https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel stable main
EOF

apt update
apt install dennco-novnc-clipboard-panel
```

## Update

Once installed from the APT repo, updates are handled normally:

```bash
apt update
apt upgrade
```

Or upgrade only this package:

```bash
apt install --only-upgrade dennco-novnc-clipboard-panel
```

Package upgrades run the repair command automatically. If a Proxmox update overwrites the noVNC files, reinstalling or upgrading this package re-copies the extension files and reinjects the loader block.

## Verify install

```bash
dpkg -l | grep dennco-novnc
tail -25 /usr/share/novnc-pve/app.js
```

Expected loader block:

```javascript
/* DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER */
(function () {
  function addAsset(tag, attrs) {
    var el = document.createElement(tag);
    Object.keys(attrs).forEach(function (key) { el.setAttribute(key, attrs[key]); });
    document.head.appendChild(el);
  }
  addAsset('link', { rel: 'stylesheet', href: '/novnc/dennco-clipboard/novnc-clipboard-panel.css?v=0.1.2' });
  addAsset('script', { src: '/novnc/dennco-clipboard/novnc-clipboard-panel.js?v=0.1.2' });
})();
/* END_DENNCO_NOVNC_CLIPBOARD_PANEL_LOADER */
```

## Remove

```bash
apt remove dennco-novnc-clipboard-panel
```

To remove the repo and signing key too:

```bash
rm -f /etc/apt/sources.list.d/dennco-novnc-clipboard.list
rm -f /usr/share/keyrings/dennco-proxmox-packages.gpg
apt update
```

## Repair after Proxmox updates

The Debian package installs a repair command:

```bash
dennco-novnc-clipboard-repair
```

Run it manually if the panel disappears after a Proxmox/noVNC update:

```bash
dennco-novnc-clipboard-repair
systemctl reload pveproxy
```

## Local development install

Clone and run the direct installer from a Proxmox host:

```bash
apt update
apt install -y git
git clone https://github.com/DenncoLABS/Proxmox9.git
cd Proxmox9/extensions/novnc-clipboard-panel
bash install/easy-install.sh
```

Remove the direct install:

```bash
cd Proxmox9/extensions/novnc-clipboard-panel
bash install/easy-uninstall.sh
```

## Local package build test

Build and install the local Debian package:

```bash
cd Proxmox9/extensions/novnc-clipboard-panel
bash packaging/build-and-install-local.sh
```

Build the APT repository locally:

```bash
cd Proxmox9/extensions/novnc-clipboard-panel
bash packaging/build-apt-repo.sh
```

Generated output:

```text
packaging/apt-repo/
```

## Repository signing

The public client key is published at:

```text
https://denncolabs.github.io/Proxmox9/novnc-clipboard-panel/keys/dennco-proxmox-packages.gpg
```

The private signing key is not committed to this repository. GitHub Actions uses the private key from the repository secret:

```text
APT_GPG_PRIVATE_KEY
```

The published repo includes:

```text
dists/stable/InRelease
dists/stable/Release
dists/stable/Release.gpg
```

## Files

```text
src/novnc-clipboard-panel.js
src/novnc-clipboard-panel.css
install/easy-install.sh
install/easy-uninstall.sh
install/repair.sh
install/install.sh
install/uninstall.sh
packaging/build-deb.sh
packaging/build-and-install-local.sh
packaging/build-apt-repo.sh
packaging/publish-github-pages.sh
docs/design.md
docs/gui-repo.md
docs/github-pages-repo.md
docs/bugfix-update-flow.md
docs/signed-apt-repo.md
```

## Notes

This extension sends pasted text as keystrokes through noVNC. It does not provide true clipboard synchronization inside the guest operating system.
