# mb-status for Mabox

`mb-status` with a cleanup section, built from [musqz/mb-status-ce](https://github.com/musqz/mb-status-ce) `main`. Generated, do not edit.

- `usr/bin/mb-status`: replaces `/usr/bin/mb-status`.
- `usr/share/mb-status/mb-status-actions.sh`: new helper, sourced by `mb-status`.
- `mb-status.diff`: both as a patch against `mabox-tools`. Apply with `cd / && sudo patch -p1 < mb-status.diff`.

Cleanup settings: `~/.config/mabox/mb-status.conf`.
