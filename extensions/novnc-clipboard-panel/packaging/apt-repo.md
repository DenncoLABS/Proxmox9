# APT repository notes

This package can be installed directly with `dpkg`, or published through a custom APT repository.

## Build the package

From the extension folder:

```bash
bash packaging/build-deb.sh
```

The package is written to:

```text
packaging/dist/dennco-novnc-clipboard-panel_0.1.0_all.deb
```

## Local install test

```bash
sudo dpkg -i packaging/dist/dennco-novnc-clipboard-panel_0.1.0_all.deb
```

Remove it with:

```bash
sudo apt remove dennco-novnc-clipboard-panel
```

## Simple APT repository layout

A minimal repository can be published from a web server with this layout:

```text
repo-root/
└── dists/
    └── stable/
        └── main/
            └── binary-all/
                ├── Packages
                ├── Packages.gz
                └── dennco-novnc-clipboard-panel_0.1.0_all.deb
```

Generate package metadata:

```bash
cd repo-root/dists/stable/main/binary-all
apt-ftparchive packages . > Packages
gzip -kf Packages
```

Add the repo on a Proxmox node:

```bash
echo 'deb [trusted=yes] https://repo.example.com stable main' | sudo tee /etc/apt/sources.list.d/dennco.list
sudo apt update
sudo apt install dennco-novnc-clipboard-panel
```

For production, use a signed repository instead of `[trusted=yes]`.
