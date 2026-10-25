#!/usr/bin/env bash
# usage: ./install.sh [--uninstall]
# env:   PREFIX=/usr SUDO=sudo for a system install (default: ~/bin and ~/.local/share)
set -euo pipefail

SUDO="${SUDO:-}"
SRC=$(cd "$(dirname "$0")" && pwd)
if [[ -n ${PREFIX:-} ]]; then
    BIN="$PREFIX/bin/mb-status-ce"
    LIB="$PREFIX/share/mb-status-ce"
else
    BIN="$HOME/bin/mb-status-ce"
    LIB="$HOME/.local/share/mb-status-ce"
fi

if [[ "${1:-}" == --uninstall ]]; then
    $SUDO rm -fv "$BIN" "$LIB/mb-status-ce-actions.sh"
    $SUDO rmdir -v "$LIB" 2>/dev/null || true
    exit 0
fi

[[ -f $SRC/mb-status-ce && -f $SRC/lib/mb-status-ce-actions.sh ]] || { echo "run from the repo checkout" >&2; exit 1; }

for dep in jgmenu pacman; do
    command -v "$dep" >/dev/null || echo "warning: $dep not found" >&2
done
[[ -f /usr/share/mb-jgtools/jgtools.inc ]] || echo "warning: mb-jgtools not installed (not Mabox?)" >&2

$SUDO install -Dm755 "$SRC/mb-status-ce" "$BIN"
$SUDO install -Dm644 "$SRC/lib/mb-status-ce-actions.sh" "$LIB/mb-status-ce-actions.sh"
echo "installed $BIN"
echo "installed $LIB/mb-status-ce-actions.sh"

case ":$PATH:" in
    *":${BIN%/*}:"*) ;;
    *) echo "warning: ${BIN%/*} is not in PATH" >&2 ;;
esac

"$BIN" status >/dev/null || { echo "installed but does not run" >&2; exit 1; }
