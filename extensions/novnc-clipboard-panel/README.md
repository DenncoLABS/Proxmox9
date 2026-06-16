# noVNC Clipboard Panel

Prototype extension for adding a browser-side clipboard panel to the Proxmox noVNC console.

Goal:

- Add a clipboard button to the noVNC side control bar.
- Open a small textarea panel.
- Let the user paste text into the browser.
- Send the text into the active noVNC console as typed keystrokes.

This is an overlay prototype. It should be tested on a non-production Proxmox node before live use.

## Files

```text
src/novnc-clipboard-panel.js
src/novnc-clipboard-panel.css
install/install.sh
install/uninstall.sh
docs/design.md
```

## Install

```bash
cd extensions/novnc-clipboard-panel
sudo bash install/install.sh
```

## Remove

```bash
cd extensions/novnc-clipboard-panel
sudo bash install/uninstall.sh
```

## Notes

The first version uses paste-as-keystrokes. It does not provide true guest clipboard synchronization.
