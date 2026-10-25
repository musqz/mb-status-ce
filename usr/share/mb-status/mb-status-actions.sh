#!/usr/bin/env bash
# Sourced by mb-status. Functions only; `run` in the main script sets -euo pipefail.

CE_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/mabox/mb-status.conf"
CE_BACKUP="${XDG_DATA_HOME:-$HOME/.local/share}/mb-status/backup"
CE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
CE_TRASH="${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
CE_APPUPD="$CE_CACHE/mb-status/app-updates"

DYNAMIC=1 # menu hides rows with nothing to clean; set from dynamic_menu
bold=$'\e[1m'; red=$'\e[31m'; dim=$'\e[2m'; rst=$'\e[0m'

case $LANG in
pl*)
_A_NOT_INSTALLED=$'nie jest zainstalowany.'
_A_PRESS_KEY=$'Naciśnij dowolny klawisz, aby zamknąć'
_A_PROCEED=$'Kontynuować? [t/N] '
_A_YES='[yYtT]'
_A_CANNOT_UNDO=$'Tego nie można cofnąć.'
_A_COMMAND=$'Polecenie:'
_A_CURRENT_SIZE=$'Aktualny rozmiar:'
_A_DRY_RUN=$'Podgląd (bez zmian):'
_A_CANCELLED=$'Anulowano.'
_A_CMD_FAILED=$'Polecenie nie powiodło się.'
_A_RECOVERED=$'Odzyskano'
_A_DONE=$'Gotowe.'
_A_NOTHING_TO_REMOVE=$'Nic do usunięcia.'
_A_FILES=$'plików'
_A_AND=$'i'
_A_MORE=$'więcej'
_A_DAYS=$'dni'
_A_FAILED=$'nie powiodło się.'
_A_SOME_NOT_REMOVED=$'nie udało się usunąć niektórych elementów'
_A_JOURNAL=$'Logi journala'
_A_JOURNAL_INFO=$'Wpisy dziennika ponad limit są usuwane. Ostatnie wpisy,\nw tym dane o ostatniej awarii, zostają.'
_A_PACCACHE=$'Cache pacmana'
_A_PACCACHE_INFO=$'Stare pliki pakietów w /var/cache/pacman/pkg. Aktualizacje rolling\nczasem wymagają powrotu do starszej wersji: zachowaj co najmniej 1-2 wersje.'
_A_PACCACHE_ALL=$'Usuwa wszystkie pliki pakietów z cache. Później nie będzie\nmożna wrócić do starszej wersji. Dalej pacman zada własne pytania.'
_A_SKIPPED_UNREADABLE=$'pominięto, brak odczytu:'
_A_CONFIG_BACKUP=$'Kopia konfiguracji:'
_A_NO_ORPHANS=$'Brak pakietów osieroconych.'
_A_ORPHANS=$'Pakiety osierocone'
_A_OPTIONAL_FOR=$'opcjonalny dla'
_A_ORPH_R_INFO=$'Usuwa tylko wymienione pakiety. Zmienione pliki konfiguracji\nzostają jako .pacsave. W razie potrzeby zainstaluj ponownie z cache pacmana.'
_A_ORPH_RS_INFO=$'Usuwa pakiety i zależności, których nic innego nie potrzebuje.\nZmienione pliki konfiguracji zostają jako .pacsave.'
_A_ORPH_RNS_INFO=$'Usuwa pakiety, nieużywane zależności i ich pliki\nkonfiguracji (bez .pacsave). Na liście mogą być zależności\nopcjonalne innych pakietów: sprawdź podgląd.'
_A_BACKUP_COPY=$'skopiuj pliki /etc każdego pakietu (i usuwanych z nim zależności) do'
_A_BACKUP_THEN=$'potem'
_A_ORPH_BACKUP_INFO=$'Kopiuje pliki /etc każdego pakietu do folderu kopii z datą,\npotem usuwa go przez pacman -Rns.'
_A_AUR=$'Cache pomocnika AUR'
_A_AUR_INFO=$'Pobrane źródła i pliki budowania pakietów AUR.'
_A_THUMBS=$'Miniatury'
_A_THUMBS_ALL_INFO=$'Wszystkie miniatury. Powstają ponownie po otwarciu folderów.'
_A_THUMBS_OLD1=$'Miniatury nieużywane od'
_A_THUMBS_OLD2=$'Powstają ponownie w razie potrzeby.'
_A_CACHE_TITLE=$'Folder cache (.cache)'
_A_CACHE1=$'Pliki nieużywane i niezmieniane od'
_A_CACHE2=$'Aplikacje odbudują swoje cache.'
_A_IGNORED=$'Ignorowane:'
_A_NONE=$'brak'
_A_EDIT_LIST=$'Edytuj listę w'
_A_TRASH=$'Śmietnik'
_A_TRASH_INFO=$'Trwale usuwa wszystko ze śmietnika.'
_A_DEV_TITLE=$'Cache deweloperskie:'
_A_DEV_INFO=$'Pobrane lub zbudowane dane. Narzędzia pobiorą lub zbudują je przy następnym użyciu.'
_A_GOMOD_INFO=$'Pobrane moduły Go. Każdy moduł zostanie pobrany ponownie\nprzy następnym budowaniu; budowanie offline nie zadziała.'
_A_CARGO_INFO=$'Usuwa rozpakowane źródła i checkouty git. Pobrane\npaczki crates zostają.'
_A_CONT_TITLE=$'Kontenery:'
_A_DOCKER_INFO=$'Usuwa zatrzymane kontenery, nieużywane sieci i osierocone\nobrazy. Woluminy pozostają nietknięte.'
_A_FLATPAK_INFO=$'Usuwa środowiska, których nie potrzebuje żadna zainstalowana aplikacja.'
_A_SNAP_INFO=$'Usuwa wyłączone (stare) rewizje zainstalowanych snapów.'
_A_OLD_REVISION=$'stara rewizja'
_A_LEFTOVER=$'Pozostałe konfiguracje (.pacnew / .pacsave)'
_A_MERGE_INFO=$'Otwiera każdy plik w meld obok oryginału. Scal go,\nzachowaj nowy lub pomiń. Nic nie zmieni się bez twojego wyboru.'
_A_CHECKING=$'Sprawdzanie aktualizacji flatpak/snap...'
_A_VM=$'Maszyna wirtualna:'
_A_VM_INFO=$'Trwale usuwa dysk maszyny, jej ustawienia i migawki.'
_A_VM_RUNNING=$'jest uruchomiona. Najpierw ją wyłącz.'
_A_VM_UNKNOWN=$'Nie znaleziono maszyny:'
;;
*)
_A_NOT_INSTALLED=$'is not installed.'
_A_PRESS_KEY=$'Press any key to close'
_A_PROCEED=$'Proceed? [y/N] '
_A_YES='[yY]'
_A_CANNOT_UNDO=$'This cannot be undone.'
_A_COMMAND=$'Command:'
_A_CURRENT_SIZE=$'Current size:'
_A_DRY_RUN=$'Dry run / preview:'
_A_CANCELLED=$'Cancelled.'
_A_CMD_FAILED=$'Command failed.'
_A_RECOVERED=$'Recovered'
_A_DONE=$'Done.'
_A_NOTHING_TO_REMOVE=$'Nothing to remove.'
_A_FILES=$'files'
_A_AND=$'and'
_A_MORE=$'more'
_A_DAYS=$'days'
_A_FAILED=$'failed.'
_A_SOME_NOT_REMOVED=$'some items could not be removed'
_A_JOURNAL=$'Journal logs'
_A_JOURNAL_INFO=$'Journal entries beyond the limit are deleted. Recent entries,\nincluding the last crash info, stay.'
_A_PACCACHE=$'Pacman cache'
_A_PACCACHE_INFO=$'Old package files in /var/cache/pacman/pkg. Rolling updates\nsometimes need a downgrade: keep at least 1-2 versions.'
_A_PACCACHE_ALL=$'Removes every cached package file. No downgrade possible\nafterwards. pacman asks its own questions next.'
_A_SKIPPED_UNREADABLE=$'skipped, not readable:'
_A_CONFIG_BACKUP=$'Config backup:'
_A_NO_ORPHANS=$'No orphan packages.'
_A_ORPHANS=$'Orphan packages'
_A_OPTIONAL_FOR=$'optional for'
_A_ORPH_R_INFO=$'Removes only the listed packages. Config files you changed are\nkept as .pacsave. Reinstall from the pacman cache if needed.'
_A_ORPH_RS_INFO=$'Removes the packages and dependencies nothing else needs.\nChanged config files are kept as .pacsave.'
_A_ORPH_RNS_INFO=$'Removes the packages, unused dependencies and their config\nfiles (no .pacsave). Optional dependencies of other\npackages may be listed: check the preview.'
_A_BACKUP_COPY=$'copy /etc files of each package (and dependencies removed with it) to'
_A_BACKUP_THEN=$'then'
_A_ORPH_BACKUP_INFO=$'Copies each package\'s /etc files to a dated backup folder,\nthen removes it with pacman -Rns.'
_A_AUR=$'AUR helper cache'
_A_AUR_INFO=$'Downloaded sources and build files of AUR packages.'
_A_THUMBS=$'Thumbnails'
_A_THUMBS_ALL_INFO=$'All thumbnails. They are recreated when folders are opened.'
_A_THUMBS_OLD1=$'Thumbnails not used for'
_A_THUMBS_OLD2=$'They are recreated when needed.'
_A_CACHE_TITLE=$'Cache folder (.cache)'
_A_CACHE1=$'Files not accessed or changed for'
_A_CACHE2=$'Apps rebuild their caches.'
_A_IGNORED=$'Ignored:'
_A_NONE=$'none'
_A_EDIT_LIST=$'Edit the list in'
_A_TRASH=$'Trash'
_A_TRASH_INFO=$'Permanently deletes everything in the trash.'
_A_DEV_TITLE=$'Developer cache:'
_A_DEV_INFO=$'Downloaded or built data. Tools fetch or rebuild it on next use.'
_A_GOMOD_INFO=$'Go module downloads. Every module is fetched again on\nthe next build; offline builds fail until then.'
_A_CARGO_INFO=$'Removes unpacked sources and git checkouts. Downloaded\ncrates stay.'
_A_CONT_TITLE=$'Containers:'
_A_DOCKER_INFO=$'Removes stopped containers, unused networks and dangling\nimages. Volumes are not touched.'
_A_FLATPAK_INFO=$'Removes runtimes no installed app needs.'
_A_SNAP_INFO=$'Removes disabled (old) revisions of installed snaps.'
_A_OLD_REVISION=$'old revision'
_A_LEFTOVER=$'Leftover configs (.pacnew / .pacsave)'
_A_MERGE_INFO=$'Opens each file in meld next to the original. Merge it,\nkeep the new one or skip it. Nothing is changed without your choice.'
_A_CHECKING=$'Checking flatpak/snap updates...'
_A_VM=$'Virtual machine:'
_A_VM_INFO=$'Permanently deletes the VM disk, its settings and snapshots.'
_A_VM_RUNNING=$'is running. Shut it down first.'
_A_VM_UNKNOWN=$'VM not found:'
;;
esac

init_conf() {
    [[ -f $CE_CONF ]] && return 0
    mkdir -p "$(dirname "$CE_CONF")"
    cat > "$CE_CONF" <<'EOF'
# mb-status cleanup settings
# days without access/modification before a file in ~/.cache counts as stale
cache_days=30
# same for ~/.cache/thumbnails
thumb_days=14
# top-level names in ~/.cache that are never touched (space separated)
cache_ignore=borg betterlockscreen mozilla firefox floorp waterfox firedragon zen chromium google-chrome BraveSoftware vivaldi librewolf paru yay pamac mabox jgmenu mb-status fontconfig
# folders with quickemu VMs, comma separated (<name>.conf next to a <name>/ folder)
qemu_dir=~/emu
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
    echo "${red}$1 $_A_NOT_INSTALLED${rst}"
    pause
    exit 1
}

pause() { read -rsn1 -p "${dim}${_A_PRESS_KEY}${rst}" || true; echo; }
ask() { local a; read -rp "$_A_PROCEED" a || return 1; [[ $a == $_A_YES ]]; }

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
    ((DANGER)) && printf '%s%s%s\n\n' "$red" "$_A_CANNOT_UNDO" "$rst"
    printf '%s\n  $ %s\n\n' "$_A_COMMAND" "$cmdtxt"
    before=$(measure)
    [[ -n $before && -z $MEASURE_FN ]] && printf '%s %s\n\n' "$_A_CURRENT_SIZE" "$(human "$before")"
    if ((${#DRY[@]})); then
        echo "${dim}${_A_DRY_RUN}${rst}"
        "${DRY[@]}" || true
        echo
    fi
    if ! ask; then echo "$_A_CANCELLED"; pause; return 0; fi
    echo
    "${CMD[@]}" || echo "${red}${_A_CMD_FAILED}${rst}"
    echo
    if [[ -n $before ]]; then
        after=$(measure)
        local diff=$((before - after))
        ((diff < 0)) && diff=0
        echo "$_A_RECOVERED $(human "$diff")"
    else
        echo "$_A_DONE"
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
    if ((${#STALE[@]} == 0)); then echo "$_A_NOTHING_TO_REMOVE"; return 0; fi
    local size
    size=$(printf '%s\0' "${STALE[@]}" | du -sbc --files0-from=- 2>/dev/null | awk 'END{print $1+0}')
    echo "${#STALE[@]} $_A_FILES, $(human "$size")"
    printf '  %s\n' "${STALE[@]:0:12}"
    ((${#STALE[@]} > 12)) && echo "  ... $_A_AND $((${#STALE[@]} - 12)) $_A_MORE"
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
    TITLE="$_A_JOURNAL"
    INFO="$_A_JOURNAL_INFO"
    DRY=(journalctl --disk-usage)
    MEASURE_FN=journal_bytes
    flow
}

act_paccache() {
    need paccache
    TITLE="$_A_PACCACHE"
    INFO="$_A_PACCACHE_INFO"
    MEASURE=(/var/cache/pacman/pkg)
    case $1 in
        k3) CMD=(sudo paccache -rk3); DRY=(paccache -dk3) ;;
        k1) CMD=(sudo paccache -rk1); DRY=(paccache -dk1) ;;
        uninstalled) CMD=(sudo paccache -ruk0); DRY=(paccache -duk0) ;;
        all)
            CMD=(sudo pacman -Scc); DRY=()
            DANGER=1
            INFO="$_A_PACCACHE_ALL" ;;
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
                echo "  $_A_SKIPPED_UNREADABLE $f"
            fi
        done < <(pacman -Ql "$p" | awk '{print $2}' | grep '^/etc/' || true)
    done
    echo "$_A_CONFIG_BACKUP $d"
    sudo pacman -Rns "${PK[@]}"
}

act_orphans() {
    need pacman
    mapfile -t PK < <(orphans)
    if ((${#PK[@]} == 0)); then
        echo "$_A_NO_ORPHANS"
        pause
        return 0
    fi
    TITLE="$_A_ORPHANS (${#PK[@]})"
    MEASURE_FN=root_used
    case $1 in
        review)
            printf '%s%s%s\n\n' "$bold" "$TITLE" "$rst"
            # largest first; the pager only starts when the list does not fit the window
            { LC_ALL=C pacman -Qi "${PK[@]}" | awk -v of="$_A_OPTIONAL_FOR" '
                function val(  v) { v = $0; sub(/^[^:]*: +/, "", v); return v }
                /^Name/ { n = val() }
                /^Version/ { v = val() }
                /^Description/ { d = val() }
                /^Optional For/ { o = val() }
                /^Installed Size/ {
                    split(val(), z, " ")
                    m = (z[2] == "KiB") ? 1024 : (z[2] == "MiB") ? 1048576 : (z[2] == "GiB") ? 1073741824 : 1
                    printf "%d\t%s %s (%s %s) %s%s\n", z[1] * m, n, v, z[1], z[2], d, (o != "None" ? "  [" of ": " o "]" : "")
                }' | sort -rn | cut -f2- | less -FRSX; } || true
            echo
            pause
            return 0 ;;
        R)
            CMD=(sudo pacman -R "${PK[@]}")
            DRY=(pacman -R --print --print-format '%n %v' "${PK[@]}")
            INFO="$_A_ORPH_R_INFO" ;;
        Rs)
            CMD=(sudo pacman -Rs "${PK[@]}")
            DRY=(pacman -Rs --print --print-format '%n %v' "${PK[@]}")
            INFO="$_A_ORPH_RS_INFO" ;;
        Rns)
            CMD=(sudo pacman -Rns "${PK[@]}")
            DRY=(pacman -Rs --print --print-format '%n %v' "${PK[@]}")
            DANGER=1
            INFO="$_A_ORPH_RNS_INFO" ;;
        backup)
            CMD=(orphan_backup_remove)
            SHOW="$_A_BACKUP_COPY $CE_BACKUP/<date>/, $_A_BACKUP_THEN sudo pacman -Rns <orphans>"
            DRY=(pacman -Rs --print --print-format '%n %v' "${PK[@]}")
            INFO="$_A_ORPH_BACKUP_INFO" ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    INFO="$(printf '  %s\n' "${PK[@]}")

$INFO"
    flow
}

act_aur() {
    TITLE="$_A_AUR"
    INFO="$_A_AUR_INFO"
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
    TITLE="$_A_THUMBS"
    if [[ ${1:-} == all ]]; then
        days=-1
        INFO="$_A_THUMBS_ALL_INFO"
        SHOW="find ~/.cache/thumbnails -type f -delete"
    else
        days=$(conf_days thumb_days 14)
        INFO="$_A_THUMBS_OLD1 $days $_A_DAYS. $_A_THUMBS_OLD2"
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
    TITLE="$_A_CACHE_TITLE"
    INFO="$_A_CACHE1 $days $_A_DAYS. $_A_CACHE2
$_A_IGNORED ${ign:-$_A_NONE}
$_A_EDIT_LIST $CE_CONF"
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
        [[ -d $CE_TRASH/$d ]] && find "$CE_TRASH/$d" -mindepth 1 -delete || echo "$_A_SOME_NOT_REMOVED"
    done
    return 0
}

trash_preview() { find "$CE_TRASH/files" -mindepth 1 -maxdepth 1 -printf "  %f\n" 2>/dev/null | head -15 || true; }

act_trash() {
    TITLE="$_A_TRASH"
    INFO="$_A_TRASH_INFO"
    DANGER=1
    SHOW="find ~/.local/share/Trash/{files,info,expunged} -mindepth 1 -delete"
    DRY=(trash_preview); CMD=(empty_trash)
    MEASURE=("$CE_TRASH")
    flow
}

act_dev() {
    TITLE="$_A_DEV_TITLE $1"
    INFO="$_A_DEV_INFO"
    case $1 in
        go) need go; CMD=(go clean -cache); MEASURE=("$(go env GOCACHE)") ;;
        gomod)
            need go; CMD=(go clean -modcache); MEASURE=("$(go env GOMODCACHE)")
            DANGER=1
            INFO="$_A_GOMOD_INFO" ;;
        npm-verify) need npm; CMD=(npm cache verify); MEASURE=("$(npm config get cache)/_cacache") ;;
        npm) need npm; CMD=(npm cache clean --force); MEASURE=("$(npm config get cache)/_cacache") ;;
        cargo)
            need cargo-cache; CMD=(cargo cache --autoclean)
            MEASURE=("${CARGO_HOME:-$HOME/.cargo}/registry")
            INFO="$_A_CARGO_INFO" ;;
        pip) need pip; CMD=(pip cache purge); MEASURE=("$(pip cache dir)") ;;
        yarn) need yarn; CMD=(yarn cache clean); MEASURE=("$(yarn cache dir)") ;;
        pnpm) need pnpm; CMD=(pnpm store prune); MEASURE=("$(pnpm store path)") ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    flow
}

snap_old() { snap list --all | awk '/disabled/{print $1, $3}'; }

# the checks below back the menu rows: true only when the action would find something;
# with DYNAMIC=0 they only test that the tool exists
dyn_has() { ((!DYNAMIC)) || has_files "$@"; }

has_files() { [[ -n $(find "$@" -type f -print -quit 2>/dev/null) ]]; }

snap_has_old() {
    ((DYNAMIC)) || { hash snap 2>/dev/null; return; }
    app_usable snap && [[ -n $(snap_old 2>/dev/null) ]]
}

flatpak_unused() {
    hash flatpak 2>/dev/null || return 1
    ((DYNAMIC)) || return 0
    LC_ALL=C timeout 5 flatpak uninstall --unused --assumeno 2>&1 </dev/null | grep -q -E '^ *1\.'
}

docker_prunable() {
    ((DYNAMIC)) || { hash docker 2>/dev/null; return; }
    hash docker 2>/dev/null && timeout 3 docker info >/dev/null 2>&1 || return 1
    [[ -n $(timeout 3 docker ps -aq -f status=exited -f status=created 2>/dev/null) ||
       -n $(timeout 3 docker images -qf dangling=true 2>/dev/null) ]]
}

# folders from qemu_dir (comma separated, ~ and $HOME expanded), in config order
VMDIRS=()
vm_load() {
    local list part d parts
    list=$(conf_get qemu_dir "$HOME/emu")
    VMDIRS=()
    IFS=, read -ra parts <<<"$list"
    for part in "${parts[@]}"; do
        d=${part#"${part%%[![:space:]]*}"}; d=${d%"${d##*[![:space:]]}"}
        d=${d/#\~/$HOME}; d=${d/#\$HOME/$HOME}; d=${d%/}
        [[ -n $d && " ${VMDIRS[*]} " != *" $d "* ]] && VMDIRS+=("$d")
    done
    return 0
}

vm_dirs_exist() { local d; for d in "${VMDIRS[@]}"; do [[ -d $d ]] && return 0; done; return 1; }

# quickemu VMs as "<folder index>:<name>": <name>.conf next to a <name>/ folder;
# names that are unsafe in a command line, and symlinks, are skipped
vm_ids() {
    local i d c n
    for i in "${!VMDIRS[@]}"; do
        d=${VMDIRS[i]}
        for c in "$d"/*.conf; do
            [[ -f $c ]] || continue
            n=${c##*/}; n=${n%.conf}
            [[ $n =~ ^[A-Za-z0-9][A-Za-z0-9._@+-]*$ && -d $d/$n && ! -L $d/$n ]] && echo "$i:$n"
        done
    done
}

vm_path() { echo "${VMDIRS[${1%%:*}]}/${1#*:}"; } # id -> folder; the .conf is "$(vm_path id).conf"

vm_size() { local p; p=$(vm_path "$1"); bytes_of "$p" "$p.conf"; }

vm_date() { # last change of the disk, else of the folder
    local f; f="$(vm_path "$1")/disk.qcow2"
    [[ -f $f ]] || f=$(vm_path "$1")
    date -r "$f" +%F
}

vm_running() { # quickemu keeps the qemu pid in <name>/<name>.pid
    local pid
    pid=$(cat "$(vm_path "$1")/${1#*:}.pid" 2>/dev/null) || return 1
    [[ $pid =~ ^[0-9]+$ && $(cat "/proc/$pid/comm" 2>/dev/null) == qemu* ]]
}

dev_has() { # tool
    case $1 in
        go) hash go 2>/dev/null && { ((!DYNAMIC)) || has_files "$(go env GOCACHE)"; } ;;
        gomod) hash go 2>/dev/null && { ((!DYNAMIC)) || has_files "$(go env GOMODCACHE)"; } ;;
        npm) hash npm 2>/dev/null && dyn_has "${npm_config_cache:-$HOME/.npm}/_cacache" ;;
        cargo) hash cargo-cache 2>/dev/null && dyn_has "${CARGO_HOME:-$HOME/.cargo}/registry" ;;
        pip) hash pip 2>/dev/null && dyn_has "$CE_CACHE/pip" ;;
        yarn) hash yarn 2>/dev/null && dyn_has "$CE_CACHE/yarn" ;;
        pnpm) hash pnpm 2>/dev/null && dyn_has "${XDG_DATA_HOME:-$HOME/.local/share}/pnpm/store" ;;
    esac
}

snap_remove_old() {
    local name rev
    while read -r name rev; do
        sudo snap remove "$name" --revision="$rev"
    done < <(snap_old)
}

act_containers() {
    local d=()
    TITLE="$_A_CONT_TITLE $1"
    case $1 in
        docker)
            need docker
            d=(docker); docker info >/dev/null 2>&1 || d=(sudo docker)
            INFO="$_A_DOCKER_INFO"
            DRY=("${d[@]}" system df); CMD=("${d[@]}" system prune) ;;
        flatpak)
            need flatpak
            INFO="$_A_FLATPAK_INFO"
            CMD=(flatpak uninstall --unused)
            MEASURE=(/var/lib/flatpak "$HOME/.local/share/flatpak") ;;
        snap)
            need snap
            INFO="$_A_SNAP_INFO"
            DRY=(snap_old); CMD=(snap_remove_old)
            SHOW="sudo snap remove <name> --revision=<$_A_OLD_REVISION>"
            MEASURE=(/var/lib/snapd/snaps) ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
    flow
}

act_leftover() {
    need pacdiff
    TITLE="$_A_LEFTOVER"
    case $1 in
        list)
            printf '%s%s%s\n\n' "$bold" "$TITLE" "$rst"
            pacdiff -o || true
            echo
            pause ;;
        merge)
            need meld
            INFO="$_A_MERGE_INFO"
            DRY=(pacdiff -o); CMD=(env DIFFPROG=meld pacdiff --sudo)
            flow ;;
        *) echo "unknown mode: $1"; exit 2 ;;
    esac
}

act_vm() {
    local id=${1:-} v ok=0 p
    vm_load
    while read -r v; do [[ $v == "$id" ]] && ok=1; done < <(vm_ids)
    ((ok)) || { echo "$_A_VM_UNKNOWN $id"; pause; return 0; }
    p=$(vm_path "$id")
    if vm_running "$id"; then echo "${red}${id#*:} $_A_VM_RUNNING${rst}"; pause; return 0; fi
    TITLE="$_A_VM ${id#*:}"
    INFO="$_A_VM_INFO"
    DANGER=1
    CMD=(rm -rf -- "$p" "$p.conf")
    DRY=(ls -la -- "$p")
    MEASURE=("$p" "$p.conf")
    flow
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
    hash tint2-send 2>/dev/null && tint2-send refresh-execp mb-status 2>/dev/null || true
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

# panel poll: refresh the flatpak/snap counts in the background when they are older than 3 hours
app_refresh() {
    local up
    [[ -z $(find "$CE_APPUPD" -mmin -180 -print -quit 2>/dev/null) ]] || return 0
    read -r up _ </proc/uptime
    ((${up%.*} > 300)) || return 0 # network is not up right after login
    { app_update_on flatpak && app_usable flatpak; } || { app_update_on snap && app_usable snap; } || return 0
    mkdir -p "${CE_APPUPD%/*}"
    setsid -f flock -n "$CE_APPUPD.lock" "$SELF" run appcheck >/dev/null 2>&1 </dev/null
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
    "${CMD[@]}" || echo "${red}${CMD[*]} $_A_FAILED${rst}"
    if app_update_on flatpak && app_usable flatpak; then
        echo; flatpak update || echo "${red}flatpak update $_A_FAILED${rst}"
    fi
    if app_update_on snap && app_usable snap; then
        echo; sudo snap refresh || echo "${red}snap refresh $_A_FAILED${rst}"
    fi
    echo; echo "$_A_CHECKING"
    act_appcheck
    echo
    pause
}

act_keys() {
    local keys=(archlinux-keyring mabox-keyring)
    if hash pacman-mirrors 2>/dev/null; then keys=(archlinux-keyring manjaro-keyring mabox-keyring)
    elif hash cachyos-kernel-manager 2>/dev/null; then keys=(archlinux-keyring cachyos-keyring mabox-keyring)
    fi
    sudo pacman -Syu "${keys[@]}" || echo "${red}pacman -Syu $_A_FAILED${rst}"
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
        vm) act_vm "$m" ;;
        sysupdate) act_sysupdate "$m" ;;
        keys) act_keys ;;
        appcheck) act_appcheck ;;
        *) echo "unknown action: $a"; exit 2 ;;
    esac
}
