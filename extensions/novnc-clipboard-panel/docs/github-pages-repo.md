# GitHub Pages option

One easy hosting option is GitHub Pages.

Use this shape:

```text
https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel
```

The package files must be placed at that path so the folder contains:

```text
dists/stable/main/binary-all/Packages
dists/stable/main/binary-all/Packages.gz
dists/stable/main/binary-all/dennco-novnc-clipboard-panel_0.1.0_all.deb
```

Build the files with:

```bash
cd Proxmox9/extensions/novnc-clipboard-panel
bash packaging/build-apt-repo.sh
```

Then copy the generated `packaging/apt-repo/` contents into a published site folder named:

```text
novnc-clipboard-panel
```

After GitHub Pages is enabled, the Proxmox source line would be:

```text
deb https://dustinlbayn.github.io/Proxmox9/novnc-clipboard-panel stable main
```

Use a signed package source for production.
