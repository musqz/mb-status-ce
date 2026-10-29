# Changelog

## Unreleased

- Show the size of old snap revisions in the menu and terminal.
- Show the old snap revisions size on the Containers row.
- Move the Trash row above Downloads.
- Show the reclaimable size per pacman cache option.
- Show the journal state and set a permanent journald limit.
- Show the journal limit in the title and mark the active permanent limit.
- Flag the pacman cache red only when 1G or more can be pruned.
- Don't flag the AUR cache and VM rows red.

## v1.1.4 - 2026-10-26

- Check only ticked flatpak/snap apps after a system update.

## v1.1.3 - 2026-10-26

- Return to the AUR picker after a removal.

## v1.1.2 - 2026-10-26

- Write `update_flatpak`, `update_snap` and `dynamic_menu` to the default config.

## v1.1.1 - 2026-10-26

- Add a subtitle under the banner in the AUR picker.

## v1.1.0 - 2026-10-26

- Choose AUR helper cache packages to remove with fzf.
- Show the Mabox banner above the AUR picker list.

## v1.0.1 - 2026-10-25

- Run *Renew PGP keys* as a run action with a full upgrade.

## v1.0 - 2026-10-25

- Translate menu and action strings (pl/en).
- Hide cleanup rows with nothing to clean; add a setting to turn the dynamic menu off.
- Add a Virtual machines row for quickemu VMs, grouped by folder, with several folders via `qemu_dir`.
- Refresh flatpak/snap counts from the panel status call.
- Move the orphan notify checkbox to settings; remove orphan notifications.
- Add a build script for the Mabox `mb-status` variant.
