#!/usr/bin/env bash
# usage: packaging/mabox-dropin.sh [outdir]
# Builds the Mabox variant: the script renamed to mb-status, laid out like the package,
# plus mb-status.diff (patch -p1 from /) against the installed mb-status (override with STOCK=path).
set -euo pipefail

SRC=$(cd "$(dirname "$0")/.." && pwd)
OUT=${1:-$SRC/dist/mabox}
STOCK=${STOCK:-/usr/bin/mb-status}

rm -rf "$OUT/usr" "$OUT/mb-status.diff"
mkdir -p "$OUT/usr/bin" "$OUT/usr/share/mb-status"
sed -e 's/^# mb-status-ce: .*/# mb-status: updates, disk space and cleanup (jgmenu)/' -e 's/mb-status-ce/mb-status/g' "$SRC/mb-status-ce" > "$OUT/usr/bin/mb-status"
sed 's/mb-status-ce/mb-status/g' "$SRC/lib/mb-status-ce-actions.sh" > "$OUT/usr/share/mb-status/mb-status-actions.sh"
chmod 755 "$OUT/usr/bin/mb-status"
bash -n "$OUT/usr/bin/mb-status"
bash -n "$OUT/usr/share/mb-status/mb-status-actions.sh"

if [[ -f $STOCK ]]; then
    {
        diff -u --label a/usr/bin/mb-status --label b/usr/bin/mb-status "$STOCK" "$OUT/usr/bin/mb-status" || [[ $? -eq 1 ]]
        diff -u --label /dev/null --label b/usr/share/mb-status/mb-status-actions.sh /dev/null "$OUT/usr/share/mb-status/mb-status-actions.sh" || [[ $? -eq 1 ]]
    } > "$OUT/mb-status.diff"
else
    echo "warning: $STOCK not found, no diff written" >&2
fi
find "$OUT" -type f | sort
