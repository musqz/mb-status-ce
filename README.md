```
███╗   ███╗ █████╗ ██████╗  ██████╗ ██╗  ██╗
████╗ ████║██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝
██╔████╔██║███████║██████╔╝██║   ██║ ╚███╔╝ 
██║╚██╔╝██║██╔══██║██╔══██╗██║   ██║ ██╔██╗ 
██║ ╚═╝ ██║██║  ██║██████╔╝╚██████╔╝██╔╝ ██╗
╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝  Community.
```

# mb-status-ce

Fork of Mabox `mb-status` (jgmenu status menu). Same menu, plus:

- **Directory size monitor** section: journal logs, pacman cache, orphan packages, AUR helper cache, thumbnails and `~/.cache`, developer caches, containers, virtual machines, leftover configs, trash.

  Dynamic menu (default): a row shows only when there is something to clean. Settings → *Dynamic menu* off shows every row of the installed tools. Settings → *Directory size monitor* off hides the section and leaves the slim update menu.
- **Update** section: a checkbox behind *Update flatpak* and *Update snap*. Each row shows only if that tool is installed.

  Ticked: the pending updates show in the panel count, and the update runs after *Update with pacman/paru/yay*. Clicking the row only toggles the box.
- Nerd Font icons per entry.

![mb-status-ce preview](docs/preview.png)

Slim menu with the Directory size monitor off:

![mb-status-ce slim menu](docs/slim.png)

Entries for tools that are not installed are hidden:

- AUR helper cache: needs `paru`, `yay` or `pamac`.
- Developer caches: only `go`, `npm`, `cargo-cache`, `pip`, `yarn`, `pnpm` that exist.
- Containers: only `docker`, `flatpak`, `snap` that exist.
- Virtual machines: needs a `qemu_dir` folder with quickemu VMs.
- Leftover configs: needs `pacdiff`. "Review and merge" also needs `meld`.
- Update flatpak / snap rows: need `flatpak` / `snap` (snap also needs `snapd.socket` running).

Every cleanup action opens a terminal, shows the command and a preview, and asks before it runs. Root commands use `sudo`.

Orphan packages, *Back up configs then remove*:

![mb-status-ce orphans backup](docs/orphans-backup.png)

Virtual machines: quickemu VMs from the `qemu_dir` folders (default `~/emu`), grouped by folder, with size and last change per VM:

![mb-status-ce virtual machines](docs/vm-menu.png)

Deleting a VM asks first and shows what goes:

![mb-status-ce delete a virtual machine](docs/vm-delete.png)

## Configuration

`~/.config/mabox/mb-status-ce.conf` is created on first run. Open it with *Settings → Edit cleanup config*.

- `cache_days`: days without access before a file in `~/.cache` counts as stale.
- `thumb_days`: same for `~/.cache/thumbnails`.
- `cache_ignore`: names in `~/.cache` that are never touched.
- `update_flatpak`, `update_snap`: the checkboxes (`y` or `n`).
- `qemu_dir`: folders with quickemu VMs (`<name>.conf` next to a `<name>/` folder), comma separated, default `~/emu`. Example: `qemu_dir=~/emu, /mnt/data_work/emu`.
- `dynamic_menu`: `y` hides cleanup rows with nothing to clean, `n` shows every row of the tools you have installed (checkbox in Settings).

The pending flatpak and snap counts refresh in the background when the panel updates, at most every 3 hours. Run the check now with `mb-status-ce run appcheck`.

## Install

```
git clone https://github.com/musqz/mb-status-ce.git
cd mb-status-ce
./install.sh
```

Installs `~/bin/mb-status-ce` and `~/.local/share/mb-status-ce/`. Make sure `~/bin` is in `PATH` (default on Mabox).

System-wide:

```
PREFIX=/usr SUDO=sudo ./install.sh
```

## Uninstall

```
./install.sh --uninstall
```

Use the same `PREFIX` and `SUDO` as for the install. Your config `~/.config/mabox/mb-status-ce.conf` is kept.

If an earlier version installed the timer, remove it: `systemctl --user disable --now mb-status-ce-appcheck.timer`, then delete the two `mb-status-ce-appcheck.*` unit files.

## Mabox build

`packaging/mabox-dropin.sh` writes `dist/mabox/`: the script as `mb-status`, its helper under `usr/share/mb-status/` and `mb-status.diff` against the installed `mb-status`.

Apply the diff to a stock `mabox-tools` install: `cd / && sudo patch -p1 < dist/mabox/mb-status.diff`. It uses `~/.config/mabox/mb-status.conf` for the cleanup settings.

## Usage

Replace the `mb-status` commands in your tint2 panel (`~/.config/tint2/*.tint2rc`):

```
execp_command = mb-status-ce status
execp_lclick_command = mb-status-ce left
execp_rclick_command = mb-status-ce menu
```

Restart tint2 afterwards. Open the menu from a terminal or keybinding: `mb-status-ce menu`.

Requires Mabox (`jgmenu`, `mb-jgtools`) and a Nerd Font.
