# Testing mb-status-ce

`mb-status-ce` is the Mabox `mb-status` panel menu with a cleanup section: journal logs, pacman cache, orphan packages, AUR helper cache, thumbnails and `~/.cache`, trash, developer caches, containers, quickemu VMs and leftover configs. Rows with nothing to clean are hidden.

Testers wanted. Use it for a while, then tell me what you miss, what is confusing and what broke.

## Try it next to mb-status

Nothing in `/usr` is touched. The stock `mb-status` keeps working.

1. Install:
   ```
   git clone https://github.com/musqz/mb-status-ce.git
   cd mb-status-ce
   ./install.sh
   ```
2. Open the menu: `mb-status-ce menu`.
3. To use it in the panel, change the three `execp_*` commands in your `.tint2rc`. See *Usage* in the [README](../README.md).

Remove it again:

```
./install.sh --uninstall
```

Your settings file `~/.config/mabox/mb-status-ce.conf` stays. Delete it by hand if you want.

## For Mabox maintainers

`mb-status.diff` is the same code as a patch for the stock `mb-status` in `mabox-tools` (built against `20260904-1`). It adds one helper file, `usr/share/mb-status/mb-status-actions.sh`.

Get it from the [latest release](https://github.com/musqz/mb-status-ce/releases/latest) or the [`mabox` branch](https://github.com/musqz/mb-status-ce/tree/mabox). Most of it is the cleanup section and the translations.

The patch also fixes the *Renew PGP keys* entry: stock uses `read -p "${FINISHED}"`, which is never set, so the `^term(` line is not closed.

## What to try

- Open the menu, open each cleanup row, check the sizes.
- Run a cleanup action and cancel at *Proceed?*. Every action shows its command first.
- Settings: *Dynamic menu* off shows every row. *Directory size monitor* off hides the section.
- Settings: *Update flatpak* / *Update snap* checkboxes, if you use them.
- Polish: start with `LANG=pl_PL.UTF-8 mb-status-ce menu`.
- VMs: put quickemu VMs in `~/emu` or set `qemu_dir` in the settings file (comma separated).

## Feedback

Open an [issue](https://github.com/musqz/mb-status-ce/issues) with your Mabox version, what you did and what you saw.
