#!/usr/bin/env bash
# theme.sh — set the wallpaper. Colors are static (from the selected Stylix
# base16 theme), so this only drives the wallpaper, not a recolor.
set -euo pipefail

cache="$HOME/.cache/wallpaper"
wall="${1:-$(cat "$cache/last" 2>/dev/null || true)}"

if [[ -z "$wall" || ! -f "$wall" ]]; then
    echo "theme.sh: no valid wallpaper (got: '${wall:-<none>}')" >&2
    echo "usage: theme.sh /path/to/image" >&2
    exit 1
fi

mkdir -p "$cache"

if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    sleep 0.5
fi
awww img "$wall" --transition-type grow --transition-pos 0.9,0.1 --transition-fps 60 --transition-duration 0.8

echo "$wall" > "$cache/last"
echo "theme.sh: applied $(basename "$wall")"
