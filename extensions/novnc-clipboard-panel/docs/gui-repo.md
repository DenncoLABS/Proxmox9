# GUI repo notes

Proxmox cannot use a normal GitHub source URL as an update source. It needs Debian package index files and a deb package.

This extension can build the needed files with:

```bash
cd Proxmox9/extensions/novnc-clipboard-panel
bash packaging/build-apt-repo.sh
```

The generated folder is:

```text
packaging/apt-repo/
```

Put that folder on a web site. The source line will look like this:

```text
deb https://example.com/novnc-clipboard-panel stable main
```

Then run:

```bash
apt update
apt install dennco-novnc-clipboard-panel
```

To make it visible in Proxmox, place the source line in a file under:

```text
/etc/apt/sources.list.d/
```

For early sandbox testing, unsigned local sources may be allowed. For real use, sign the package source.
