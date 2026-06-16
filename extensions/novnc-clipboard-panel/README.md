# noVNC Clipboard Panel

Prototype extension for adding a browser-side clipboard panel to the Proxmox noVNC console.

Goal:

- Add a clipboard button to the noVNC side control bar.
- Open a small textarea panel.
- Let the user paste text into the browser.
- Send the text into the active noVNC console as typed keystrokes.

This is an overlay prototype. It should be tested on a non-production Proxmox node before live use.

## Super easy install

From the Proxmox host:

```bash
apt update
apt install -y git
git clone https://github.com/dustinlbayn/Proxmox9.git
cd Proxmox9/extensions/novnc-clipboard-panel
sudo bash install/easy-install.sh
```

Then open the VM console in a private browser window, or hard-refresh the noVNC page.

## Super easy remove

```bash
cd Proxmox9/extensions/novnc-clipboard-panel
sudo bash install/easy-uninstall.sh
```

## Package install test

Build and install the local Debian package:

```bash
cd Proxmox9/extensions/novnc-clipboard-panel
sudo bash packaging/build-and-install-local.sh
```

Remove the package:

```bash
sudo apt remove dennco-novnc-clipboard-panel
```

## Repair after updates

The Debian package now installs a repair command:

```bash
sudo dennco-novnc-clipboard-repair
```

Package upgrades call this automatically. If a Proxmox update overwrites the noVNC HTML file, the next package upgrade will re-copy the latest files and re-inject the clipboard panel.

APT only upgrades when the package version increases. Bugfix releases must bump the package version.

See:

```text
docs/bugfix-update-flow.md
```

## APT repo build

Build files for a web-hosted package source:

```bash
cd Proxmox9/extensions/novnc-clipboard-panel
bash packaging/build-apt-repo.sh
```

Generated output:

```text
packaging/apt-repo/
```

See:

```text
docs/gui-repo.md
docs/github-pages-repo.md
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
docs/design.md
docs/gui-repo.md
docs/github-pages-repo.md
docs/bugfix-update-flow.md
```

## Notes

The first version uses paste-as-keystrokes. It does not provide true guest clipboard synchronization.
