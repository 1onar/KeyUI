#!/usr/bin/env bash
# Maintains the Blizzard UI source snapshots in API/<flavor>/ and checks that
# KeyUI.toc lists the interface version of every client KeyUI supports.
#
#   tools/update-api.sh check               compare upstream builds with KeyUI.toc
#                                           (and with API/, when it exists)
#   tools/update-api.sh update [flavor...]  refresh API/<flavor>/ (default: all)
#
# Sources:
#   UI code    https://github.com/Gethe/wow-ui-source              Interface/AddOns
#   Resources  https://github.com/Ketho/BlizzardInterfaceResources Resources/*.lua
#
# The resources repository trails the clients by weeks at times, so its build
# is recorded on its own in API/<flavor>/_resources/version.txt.
#
# check exits 1 when an upstream interface version is missing from KeyUI.toc and
# prints one machine-readable line per gap (read by .github/workflows/api-watch.yml):
#   MISSING <flavor> <interface> <version> <wow-ui-source branch>

set -euo pipefail

# <API folder>:<wow-ui-source branch>:<BlizzardInterfaceResources branch>
# Adding a client (a PTR, classic_titan, ...) only needs a line here.
FLAVORS=(
    "retail:live:live"
    "forever:forever:forever"
    "mists:classic:classic"
    "anniversary:classic_anniversary:classic_anniversary"
    "classic_era:classic_era:classic_era"
)

RESOURCE_FILES=(AtlasInfo.lua GlobalAPI.lua Templates.lua)

UI_SOURCE_RAW="https://raw.githubusercontent.com/Gethe/wow-ui-source"
UI_SOURCE_TARBALL="https://codeload.github.com/Gethe/wow-ui-source/tar.gz/refs/heads"
RESOURCES_RAW="https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources"
RESOURCES_API="https://api.github.com/repos/Ketho/BlizzardInterfaceResources/commits"

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TOC="$ROOT/KeyUI.toc"
API_DIR="$ROOT/API"

die() {
    echo "update-api: $*" >&2
    exit 2
}

fetch() {
    curl -fsSL --retry 3 "$@"
}

# 12.1.5.70448 -> 120105, 1.60.1.70450 -> 16001
interface_of() {
    local major minor patch
    IFS=. read -r major minor patch _ <<< "$1"
    echo $(( 10#$major * 10000 + 10#$minor * 100 + 10#$patch ))
}

upstream_version() {
    fetch "$UI_SOURCE_RAW/$1/version.txt" | tr -d '\r\n '
}

local_version() {
    if [[ -f "$API_DIR/$1/version.txt" ]]; then
        tr -d '\r\n ' < "$API_DIR/$1/version.txt"
    fi
}

toc_lists() {
    sed -n 's/^## Interface:[[:space:]]*//p' "$TOC" | tr ',' '\n' | tr -d ' \r' | grep -qx "$1"
}

# Resolves the flavor names given on the command line to FLAVORS entries.
select_flavors() {
    local name entry found
    if (( $# == 0 )); then
        printf '%s\n' "${FLAVORS[@]}"
        return
    fi
    for name in "$@"; do
        found=
        for entry in "${FLAVORS[@]}"; do
            if [[ ${entry%%:*} == "$name" ]]; then
                printf '%s\n' "$entry"
                found=1
            fi
        done
        [[ -n $found ]] || die "unknown flavor '$name' (known: $(printf '%s ' "${FLAVORS[@]%%:*}"))"
    done
}

cmd_check() {
    local entry flavor branch upstream interface current snapshot toc status=0
    local missing=()

    [[ -f $TOC ]] || die "$TOC not found"

    printf '%-12s %-14s %-10s %-4s %s\n' FLAVOR UPSTREAM INTERFACE TOC SNAPSHOT
    for entry in "${FLAVORS[@]}"; do
        IFS=: read -r flavor branch _ <<< "$entry"
        upstream=$(upstream_version "$branch")
        interface=$(interface_of "$upstream")
        current=$(local_version "$flavor")

        if toc_lists "$interface"; then
            toc=ok
        else
            toc=no
            status=1
            missing+=("MISSING $flavor $interface $upstream $branch")
        fi

        if [[ -z $current ]]; then
            snapshot=-
        elif [[ $current == "$upstream" ]]; then
            snapshot="current"
        else
            snapshot="outdated ($current)"
        fi

        printf '%-12s %-14s %-10s %-4s %s\n' "$flavor" "$upstream" "$interface" "$toc" "$snapshot"
    done

    if (( ${#missing[@]} )); then
        echo
        printf '%s\n' "${missing[@]}"
    fi
    return "$status"
}

# Lists what changed in Blizzard_APIDocumentationGenerated: ~ changed, + new, - removed.
# -w: client exports lack the final newline that wow-ui-source adds, which
# would otherwise flag every file when comparing against such a snapshot.
api_doc_changes() {
    local old="$1/Blizzard_APIDocumentationGenerated" new="$2/Blizzard_APIDocumentationGenerated"
    local changes

    [[ -d $old && -d $new ]] || return 0
    changes=$( { LC_ALL=C diff -rqw "$old" "$new" || true; } | sed \
        -e "s|^Files $old/\(.*\) and .* differ\$|    ~ \1|" \
        -e "s|^Only in $old: |    - |" \
        -e "s|^Only in $new: |    + |")
    echo "  API documentation changes:"
    if [[ -n $changes ]]; then
        echo "$changes"
    else
        echo "    (none)"
    fi
}

cmd_update() {
    local entry flavor branch res_branch upstream current staging archive top version res_version file
    local entries

    entries=$(select_flavors "$@")
    mkdir -p "$API_DIR"

    # Staged next to the snapshots so the final mv is a rename, not a copy.
    # Global, so the EXIT trap can still see it after this function returns.
    WORK=$(mktemp -d "$API_DIR/.work.XXXXXX")
    trap 'rm -rf "$WORK"' EXIT

    while IFS= read -r entry; do
        IFS=: read -r flavor branch res_branch <<< "$entry"
        upstream=$(upstream_version "$branch")
        current=$(local_version "$flavor")

        if [[ $current == "$upstream" ]]; then
            echo "$flavor: up to date ($upstream)"
            continue
        fi
        echo "$flavor: ${current:-none} -> $upstream"

        archive="$WORK/$flavor.tar.gz"
        staging="$WORK/$flavor"
        top="wow-ui-source-${branch//\//-}"
        fetch "$UI_SOURCE_TARBALL/$branch" -o "$archive"

        # Taken from the archive itself; the branch may have moved since upstream_version.
        version=$(tar -xzOf "$archive" "$top/version.txt" | tr -d '\r\n ')
        mkdir -p "$staging/_resources"
        tar -xzf "$archive" -C "$staging" --strip-components=3 "$top/Interface/AddOns"
        rm -f "$archive"
        printf '%s\n' "$version" > "$staging/version.txt"

        for file in "${RESOURCE_FILES[@]}"; do
            fetch "$RESOURCES_RAW/$res_branch/Resources/$file" -o "$staging/_resources/$file"
        done
        res_version=$(fetch "$RESOURCES_API/$res_branch" 2>/dev/null \
            | sed -n '/"message"/{s/.*"message": *"\([^"]*\)".*/\1/p;q;}' || true)
        printf '%s\n' "${res_version:-unknown}" > "$staging/_resources/version.txt"

        if [[ -d "$API_DIR/$flavor" ]]; then
            api_doc_changes "$API_DIR/$flavor" "$staging"
            mv "$API_DIR/$flavor" "$WORK/$flavor.old"
        fi
        mv "$staging" "$API_DIR/$flavor"
        echo "  snapshot $version, resources ${res_version:-unknown}"
    done <<< "$entries"

    local legacy=()
    shopt -s nullglob
    legacy=("$API_DIR"/[0-9]*/)
    shopt -u nullglob
    if (( ${#legacy[@]} )); then
        echo
        echo "Legacy snapshot folders are no longer used and can be deleted:"
        printf '  %s\n' "${legacy[@]#"$ROOT/"}"
    fi
}

case "${1:-}" in
    check)
        shift
        cmd_check "$@"
        ;;
    update)
        shift
        cmd_update "$@"
        ;;
    *)
        echo "usage: $0 check | update [flavor...]" >&2
        exit 2
        ;;
esac
