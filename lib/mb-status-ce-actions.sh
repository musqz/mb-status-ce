#!/usr/bin/env bash
# Sourced by mb-status-ce. Functions only; `run` in the main script sets -euo pipefail.

CE_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/mabox/mb-status-ce.conf"
CE_BACKUP="${XDG_DATA_HOME:-$HOME/.local/share}/mb-status-ce/backup"
CE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
CE_TRASH="${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
CE_APPUPD="$CE_CACHE/mb-status-ce/app-updates"
CE_ORPHSEEN="$CE_CACHE/mb-status-ce/orphans-notified"

bold=$'\e[1m'; red=$'\e[31m'; dim=$'\e[2m'; rst=$'\e[0m'

init_conf() {
    [[ -f $CE_CONF ]] && return 0
    mkdir -p "$(dirname "$CE_CONF")"
    cat > "$CE_CONF" <<'EOF'
# mb-status-ce cleanup settings
# days without access/modification before a file in ~/.cache counts as stale
cache_days=30
# same for ~/.cache/thumbnails
thumb_days=14
# top-level names in ~/.cache that are never touched (space separated)
cache_ignore=borg betterlockscreen mozilla firefox floorp waterfox firedragon zen chromium google-chrome BraveSoftware vivaldi librewolf paru yay pamac mabox jgmenu mb-status-ce fontconfig
EOF
}

conf_get() { # key default
    local v
    v=$(sed -n "s/^$1=//p" "$CE_CONF" 2>/dev/null | tail -n1 || true)
    v=${v//\"/}
    echo "${v:-$2}"
}

conf_days() { # key default
    local d
    d=$(conf_get "$1" "$2")
    [[ $d =~ ^[0-9]+$ ]] || d=$2
    echo "$d"
}

bytes_of() {
    local n
    n=$(du -sbc -- "$@" 2>/dev/null | awk 'END{print $1+0}') || true
    echo "${n:-0}"
}

human() { LC_ALL=C numfmt --to=iec "${1:-0}"; }

journal_bytes() {
    local v
    v=$(LC_ALL=C journalctl --disk-usage 2>/dev/null | sed -n 's/.*take up \([0-9.]*[KMGT]*\)B\? .*/\1/p')
    LC_ALL=C numfmt --from=iec "${v:-0}"
}

root_used() { df --output=used -B1 / | tail -n1 | tr -d ' '; }

orphans() { pacman -Qdtq 2>/dev/null || true; }

# installed size of what pacman -Rs/-Rns would remove for the given orphans; prints nothing on failure
# (pacman rejects -n together with --print, so -Rs stands in for -Rns)
orphan_bytes() {
    local all
    (($#)) || { echo 0; return; }
    mapfile -t all < <(pacman -Rs --print --print-format '%n' "$@" 2>/dev/null)
    ((${#all[@]})) || return 0
    LC_ALL=C pacman -Qi "${all[@]}" 2>/dev/null | awk '
        /^Installed Size/ {
            split($0, a, ": +"); split(a[2], z, " ")
            t += z[1] * ((z[2] == "KiB") ? 1024 : (z[2] == "MiB") ? 1048576 : (z[2] == "GiB") ? 1073741824 : 1)
        }
        END { printf "%d\n", t }'
}

need() {
    hash "$1" 2>/dev/null && return 0
    echo "${red}$1 is not installed.${rst}"
    pause
    exit 1
}

pause() { read -rsn1 -p "${dim}Press any key to close${rst}" || true; echo; }
ask() { local a; read -rp "Proceed? [y/N] " a || return 1; [[ $a == [yY] ]]; }

# Globals set by each action, consumed by flow()
TITLE=""; INFO=""; DANGER=0; SHOW=""; MEASURE_FN=""
DRY=(); CMD=(); MEASURE=()

measure() {
    if [[ -n $MEASURE_FN ]]; then "$MEASURE_FN"
    elif ((${#MEASURE[@]})); then bytes_of "${MEASURE[@]}"
    else echo ""
    fi
}

flow() {
    local before after cmdtxt
    cmdtxt=${SHOW:-$(printf '%q ' "${CMD[@]}")}
    printf '%s%s%s\n%s\n\n' "$bold" "$TITLE" "$rst" "$INFO"
    ((DANGER)) && printf '%sThis cannot be undone.%s\n\n' "$red" "$rst"
    printf 'Command:\n  $ %s\n\n' "$cmdtxt"
    before=$(measure)
    [[ -n $before && -z $MEASURE_FN ]] && printf 'Current size: %s\n\n' "$(human "$before")"
    if ((${#DRY[@]})); then
        echo "${dim}Dry run / preview:${rst}"
        "${DRY[@]}" || true
        echo
    fi
    if ! ask; then echo "Cancelled."; pause; return 0; fi
    echo
    "${CMD[@]}" || echo "${red}Command failed.${rst}"
    echo
    if [[ -n $before ]]; then
        after=$(measure)
        local diff=$((before - after))
        ((diff < 0)) && diff=0
        echo "Recovered $(human "$diff")"
    else
        echo "Done."
    fi
    pause
}

# --- stale file sweeps (ignore list only excludes top-level names) ---

STALE=()

stale_files() { # root days [ignore names...]
    local root=$1 days=$2 n args=()
    shift 2
    for n in "$@"; do
        [[ $n =~ ^[A-Za-z0-9._@+-]+$ ]] && args+=(-path "$root/$n" -prune -o)
    done
    if ((days < 0)); then
        find "$root" -type f -print0 2>/dev/null
    else
        find "$root" "${args[@]}" -type f -atime +"$days" -mtime +"$days" -print0 2>/dev/null
    fi
}

stale_load() { # root days [ignore names...]
    STALE=()
    [[ -d $1 ]] || return 0
    mapfile -d '' -t STALE < <(stale_files "$@")
}

stale_bytes() { # root days [ignore names...]
    [[ -d $1 ]] || { echo 0; return 0; }
    stale_files "$@" | du -sbc --files0-from=- 2>/dev/null | awk 'END{print $1+0}'
}

stale_preview() {
    if ((${#STALE[@]} == 0)); then echo "Nothing to remove."; return 0; fi
    local size
    size=$(printf '%s\0' "${STALE[@]}" | du -sbc --files0-from=- 2>/dev/null | awk 'END{print $1+0}')
    echo "${#STALE[@]} files, $(human "$size")"
    printf '  %s\n' "${STALE[@]:0:12}"
    ((${#STALE[@]} > 12)) && echo "  ... and $((${#STALE[@]} - 12)) more"
    return 0
}

stale_delete() {
    ((${#STALE[@]})) || return 0
    printf '%s\0' "${STALE[@]}" | xargs -0 rm -f --
}

# --- actions ---

act_journal() {
    need journalctl
    case $1 in
        1d|7d) CMD=(sudo journalctl "--vacuum-time=$1") ;;
        200M|500M) CMD=(sudo journalctl "--vacuum-size=$1") ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    TITLE="Journal logs"
    INFO="Journal entries beyond the limit are deleted. Recent entries,
including the last crash info, stay."
    DRY=(journalctl --disk-usage)
    MEASURE_FN=journal_bytes
    flow
}

act_paccache() {
    need paccache
    TITLE="Pacman cache"
    INFO="Old package files in /var/cache/pacman/pkg. Rolling updates
sometimes need a downgrade: keep at least 1-2 versions."
    MEASURE=(/var/cache/pacman/pkg)
    case $1 in
        k3) CMD=(sudo paccache -rk3); DRY=(paccache -dk3) ;;
        k1) CMD=(sudo paccache -rk1); DRY=(paccache -dk1) ;;
        uninstalled) CMD=(sudo paccache -ruk0); DRY=(paccache -duk0) ;;
        all)
            CMD=(sudo pacman -Scc); DRY=()
            DANGER=1
            INFO="Removes every cached package file. No downgrade possible
afterwards. pacman asks its own questions next." ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    flow
}

orphan_backup_remove() {
    local d p f all
    d="$CE_BACKUP/$(date +%F_%H%M%S)"
    mapfile -t all < <(pacman -Rs --print --print-format '%n' "${PK[@]}")
    for p in "${all[@]}"; do
        while read -r f; do
            [[ -f $f ]] || continue
            if [[ -r $f ]]; then
                mkdir -p "$d/$p"
                cp --parents -p -- "$f" "$d/$p/"
            else
                echo "  skipped, not readable: $f"
            fi
        done < <(pacman -Ql "$p" | awk '{print $2}' | grep '^/etc/' || true)
    done
    echo "Config backup: $d"
    sudo pacman -Rns "${PK[@]}"
}

act_orphans() {
    need pacman
    mapfile -t PK < <(orphans)
    if ((${#PK[@]} == 0)); then
        echo "No orphan packages."
        pause
        return 0
    fi
    TITLE="Orphan packages (${#PK[@]})"
    MEASURE_FN=root_used
    case $1 in
        review)
            printf '%s%s%s\n\n' "$bold" "$TITLE" "$rst"
            # largest first; the pager only starts when the list does not fit the window
            { LC_ALL=C pacman -Qi "${PK[@]}" | awk '
                function val(  v) { v = $0; sub(/^[^:]*: +/, "", v); return v }
                /^Name/ { n = val() }
                /^Version/ { v = val() }
                /^Description/ { d = val() }
                /^Optional For/ { o = val() }
                /^Installed Size/ {
                    split(val(), z, " ")
                    m = (z[2] == "KiB") ? 1024 : (z[2] == "MiB") ? 1048576 : (z[2] == "GiB") ? 1073741824 : 1
                    printf "%d\t%s %s (%s %s) %s%s\n", z[1] * m, n, v, z[1], z[2], d, (o != "None" ? "  [optional for: " o "]" : "")
                }' | sort -rn | cut -f2- | less -FRSX; } || true
            echo
            pause
            return 0 ;;
        R)
            CMD=(sudo pacman -R "${PK[@]}")
            DRY=(pacman -R --print --print-format '%n %v' "${PK[@]}")
            INFO="Removes only the listed packages. Config files you changed are
kept as .pacsave. Reinstall from the pacman cache if needed." ;;
        Rs)
            CMD=(sudo pacman -Rs "${PK[@]}")
            DRY=(pacman -Rs --print --print-format '%n %v' "${PK[@]}")
            INFO="Removes the packages and dependencies nothing else needs.
Changed config files are kept as .pacsave." ;;
        Rns)
            CMD=(sudo pacman -Rns "${PK[@]}")
            DRY=(pacman -Rs --print --print-format '%n %v' "${PK[@]}")
            DANGER=1
            INFO="Removes the packages, unused dependencies and their config
files (no .pacsave). Optional dependencies of other
packages may be listed: check the preview." ;;
        backup)
            CMD=(orphan_backup_remove)
            SHOW="copy /etc files of each package (and dependencies removed with it) to $CE_BACKUP/<date>/, then sudo pacman -Rns <orphans>"
            DRY=(pacman -Rs --print --print-format '%n %v' "${PK[@]}")
            INFO="Copies each package's /etc files to a dated backup folder,
then removes it with pacman -Rns." ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    INFO="$(printf '  %s\n' "${PK[@]}")

$INFO"
    flow
}

act_aur() {
    TITLE="AUR helper cache"
    INFO="Downloaded sources and build files of AUR packages."
    case $1 in
        paru) need paru; CMD=(paru -Sc --aur); MEASURE=("$CE_CACHE/paru") ;;
        yay) need yay; CMD=(yay -Sc --aur); MEASURE=("$CE_CACHE/yay") ;;
        pamac) need pamac; CMD=(pamac clean -b); MEASURE=("/var/tmp/pamac-build-$USER") ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    flow
}

act_thumbs() {
    local days
    TITLE="Thumbnails"
    if [[ ${1:-} == all ]]; then
        days=-1
        INFO="All thumbnails. They are recreated when folders are opened."
        SHOW="find ~/.cache/thumbnails -type f -delete"
    else
        days=$(conf_days thumb_days 14)
        INFO="Thumbnails not used for $days days. They are recreated when needed."
        SHOW="find ~/.cache/thumbnails -type f -atime +$days -mtime +$days -delete"
    fi
    stale_load "$CE_CACHE/thumbnails" "$days"
    DRY=(stale_preview); CMD=(stale_delete)
    MEASURE=("$CE_CACHE/thumbnails")
    flow
}

act_cache() {
    local days ign
    days=$(conf_days cache_days 30)
    ign=$(conf_get cache_ignore "")
    TITLE="Cache folder (.cache)"
    INFO="Files not accessed or changed for $days days. Apps rebuild
their caches. Ignored: ${ign:-none}
Edit the list in $CE_CONF"
    # shellcheck disable=SC2086
    stale_load "$CE_CACHE" "$days" $ign
    SHOW="find ~/.cache -type f -atime +$days -mtime +$days (ignore list applied) -delete"
    DRY=(stale_preview); CMD=(stale_delete)
    MEASURE=("$CE_CACHE")
    flow
}

empty_trash() {
    local d
    for d in files info expunged; do
        [[ -d $CE_TRASH/$d ]] && find "$CE_TRASH/$d" -mindepth 1 -delete || echo "some items could not be removed"
    done
    return 0
}

trash_preview() { find "$CE_TRASH/files" -mindepth 1 -maxdepth 1 -printf "  %f\n" 2>/dev/null | head -15 || true; }

act_trash() {
    TITLE="Trash"
    INFO="Permanently deletes everything in the trash."
    DANGER=1
    SHOW="find ~/.local/share/Trash/{files,info,expunged} -mindepth 1 -delete"
    DRY=(trash_preview); CMD=(empty_trash)
    MEASURE=("$CE_TRASH")
    flow
}

act_dev() {
    TITLE="Developer cache: $1"
    INFO="Downloaded or built data. Tools fetch or rebuild it on next use."
    case $1 in
        go) need go; CMD=(go clean -cache); MEASURE=("$(go env GOCACHE)") ;;
        gomod)
            need go; CMD=(go clean -modcache); MEASURE=("$(go env GOMODCACHE)")
            DANGER=1
            INFO="Go module downloads. Every module is fetched again on
the next build; offline builds fail until then." ;;
        npm-verify) need npm; CMD=(npm cache verify); MEASURE=("$(npm config get cache)/_cacache") ;;
        npm) need npm; CMD=(npm cache clean --force); MEASURE=("$(npm config get cache)/_cacache") ;;
        cargo)
            need cargo-cache; CMD=(cargo cache --autoclean)
            MEASURE=("${CARGO_HOME:-$HOME/.cargo}/registry")
            INFO="Removes unpacked sources and git checkouts. Downloaded
crates stay." ;;
        pip) need pip; CMD=(pip cache purge); MEASURE=("$(pip cache dir)") ;;
        yarn) need yarn; CMD=(yarn cache clean); MEASURE=("$(yarn cache dir)") ;;
        pnpm) need pnpm; CMD=(pnpm store prune); MEASURE=("$(pnpm store path)") ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    flow
}

snap_old() { snap list --all | awk '/disabled/{print $1, $3}'; }

snap_remove_old() {
    local name rev
    while read -r name rev; do
        sudo snap remove "$name" --revision="$rev"
    done < <(snap_old)
}

act_containers() {
    local d=()
    TITLE="Containers: $1"
    case $1 in
        docker)
            need docker
            d=(docker); docker info >/dev/null 2>&1 || d=(sudo docker)
            INFO="Removes stopped containers, unused networks and dangling
images. Volumes are not touched."
            DRY=("${d[@]}" system df); CMD=("${d[@]}" system prune) ;;
        flatpak)
            need flatpak
            INFO="Removes runtimes no installed app needs."
            CMD=(flatpak uninstall --unused)
            MEASURE=(/var/lib/flatpak "$HOME/.local/share/flatpak") ;;
        snap)
            need snap
            INFO="Removes disabled (old) revisions of installed snaps."
            DRY=(snap_old); CMD=(snap_remove_old)
            SHOW="sudo snap remove <name> --revision=<old revision>"
            MEASURE=(/var/lib/snapd/snaps) ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    flow
}

act_leftover() {
    need pacdiff
    TITLE="Leftover configs (.pacnew / .pacsave)"
    case $1 in
        list)
            printf '%s%s%s\n\n' "$bold" "$TITLE" "$rst"
            pacdiff -o || true
            echo
            pause ;;
        merge)
            need meld
            INFO="Opens each file in meld next to the original. Merge it,
keep the new one or skip it. Nothing is changed without your choice."
            DRY=(pacdiff -o); CMD=(env DIFFPROG=meld pacdiff --sudo)
            flow ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
}

appupd_get() { local v; v=$(sed -n "s/^$1=//p" "$CE_APPUPD" 2>/dev/null | tail -n1 || true); echo "${v:-0}"; } # flatpak | snap

# a failed check keeps the last known count
act_appcheck() {
    local f s tmp
    f=$(appupd_get flatpak); s=$(appupd_get snap)
    app_usable flatpak && { f=$(set -o pipefail; timeout 60 flatpak remote-ls --updates --columns=application 2>/dev/null | sort -u | wc -l) || f=$(appupd_get flatpak); }
    if app_usable snap; then
        s=$(set -o pipefail; timeout 20 snap refresh --list 2>/dev/null | tail -n +2 | wc -l) || s=$(appupd_get snap)
    fi
    mkdir -p "${CE_APPUPD%/*}"
    tmp=$(mktemp "$CE_APPUPD.XXXXXX")
    printf 'flatpak=%s\nsnap=%s\n' "$f" "$s" > "$tmp"
    mv -f "$tmp" "$CE_APPUPD"
    hash tint2-send 2>/dev/null && tint2-send refresh-execp mb-status-ce 2>/dev/null || true
}

# pending updates of a ticked, usable app; 0 otherwise
app_counted() { # flatpak | snap
    local c
    app_update_on "$1" || { echo 0; return; }
    c=$(appupd_get "$1")
    ((c > 0)) || { echo 0; return; }
    app_usable "$1" || { echo 0; return; }
    echo "$c"
}

# desktop notice with buttons when the orphan list changed; the buttons open the terminal flows
act_orphancheck() {
    [[ $(conf_get notify_orphans n) == y ]] && hash notify-send.sh 2>/dev/null || return 0
    local list n sig body ob
    mapfile -t list < <(orphans)
    n=${#list[@]}
    mkdir -p "${CE_ORPHSEEN%/*}"
    if ((n == 0)); then echo none > "$CE_ORPHSEEN"; return 0; fi
    sig=$(printf '%s\n' "${list[@]}" | sort | md5sum | cut -d' ' -f1)
    [[ $(cat "$CE_ORPHSEEN" 2>/dev/null) == "$sig" ]] && return 0
    body="${list[*]:0:5}"
    ((n > 5)) && body+=" and $((n - 5)) more"
    ob=$(orphan_bytes "${list[@]}")
    notify-send.sh -a mb-status-ce -i user-trash-full -t 120000 -f "Orphan packages: $n${ob:+ ($(human "$ob"))}" "$body" \
        -o "Review:terminator -T Orphans -x $SELF run orphans review" \
        -o "Back up and remove:terminator -T Orphans -x $SELF run orphans backup" || return 0
    echo "$sig" > "$CE_ORPHSEEN"
}

# installed, and for snap snapd must be up (the binary ships without it)
app_usable() { # flatpak | snap
    hash "$1" 2>/dev/null || return 1
    [[ $1 != snap ]] || systemctl is-active --quiet snapd.socket
}

app_update_on() { [[ $(conf_get "update_$1" n) == y ]]; } # flatpak | snap

act_sysupdate() {
    case $1 in
        paru) CMD=(paru -Syu) ;;
        paru-noaur) CMD=(paru --repo -Syu) ;;
        yay) CMD=(yay -Syu) ;;
        yay-noaur) CMD=(yay --repo -Syu) ;;
        pacman) CMD=(sudo pacman -Syu) ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    "${CMD[@]}" || echo "${red}${CMD[*]} failed.${rst}"
    if app_update_on flatpak && app_usable flatpak; then
        echo; flatpak update || echo "${red}flatpak update failed.${rst}"
    fi
    if app_update_on snap && app_usable snap; then
        echo; sudo snap refresh || echo "${red}snap refresh failed.${rst}"
    fi
    echo; echo "Checking flatpak/snap updates..."
    act_appcheck
    echo
    pause
}

run_action() { # action [mode]
    init_conf
    local a=${1:-} m=${2:-}
    case $a in
        journal) act_journal "$m" ;;
        paccache) act_paccache "$m" ;;
        orphans) act_orphans "$m" ;;
        aur) act_aur "$m" ;;
        thumbs) act_thumbs "$m" ;;
        cache) act_cache ;;
        trash) act_trash ;;
        dev) act_dev "$m" ;;
        containers) act_containers "$m" ;;
        leftover) act_leftover "$m" ;;
        sysupdate) act_sysupdate "$m" ;;
        appcheck) act_appcheck ;;
        orphancheck) act_orphancheck ;;
        *) echo "unknown action: $a"; exit 2 ;;
    esac
}
