#!/usr/bin/env bash
# Runs KeyUI headless in a stand-in WoW client (tools/harness/wow.lua) through a fixed
# session (tools/harness/run.lua) and checks every bound key against what the game
# state says it should show and click.
#
#   tools/harness/check.sh                  check the working tree on every client flavor
#   tools/harness/check.sh diff [ref]       print what changed between <ref> (default: the
#                                           latest release tag) and the working tree, step
#                                           by step, on Forever
#
# check exits 1 when any flavor reports a Lua error, an ADDON_ACTION_BLOCKED or an
# oracle mismatch. It needs lua5.1 (or luajit).

set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
HARNESS="$ROOT/tools/harness"
LUA=$(command -v lua5.1 || command -v luajit || true)
[[ -n "$LUA" ]] || { echo "check.sh: needs lua5.1 or luajit" >&2; exit 2; }

FLAVORS=(retail forever mists anniversary classic_era)

case "${1:-check}" in
    check)
        status=0
        for flavor in "${FLAVORS[@]}"; do
            KEYUI_FLAVOR=$flavor "$LUA" "$HARNESS/run.lua" "$ROOT" check || status=1
        done
        exit $status
        ;;
    diff)
        ref=${2:-$(git -C "$ROOT" describe --tags --abbrev=0 --match 'v*' --exclude '*-*' HEAD)}
        work=$(mktemp -d)
        trap 'rm -rf "$work"' EXIT
        mkdir -p "$work/base"
        git -C "$ROOT" archive "$ref" | tar -x -C "$work/base"
        KEYUI_FLAVOR=${KEYUI_FLAVOR:-forever} "$LUA" "$HARNESS/run.lua" "$work/base" dump > "$work/base.txt" 2>"$work/base.err" || true
        KEYUI_FLAVOR=${KEYUI_FLAVOR:-forever} "$LUA" "$HARNESS/run.lua" "$ROOT" dump > "$work/head.txt" 2>"$work/head.err" || true
        echo "base $ref: $(tail -n1 "$work/base.err")"
        echo "head:     $(tail -n1 "$work/head.err")"
        diff -u --label "$ref" --label "working tree" "$work/base.txt" "$work/head.txt" || true
        ;;
    *)
        echo "usage: $0 [check | diff [ref]]" >&2
        exit 2
        ;;
esac
