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

## Files

```text
src/novnc-clipboard-panel.js
src/novnc-clipboard-panel.css
install/easy-install.sh
install/easy-uninstall.sh
install/install.sh
install/uninstall.sh
packaging/build-deb.sh
packaging/build-and-install-local.sh
docs/design.md
```

## Notes

The first version uses paste-as-keystrokes. It does not provide true guest clipboard synchronization.
