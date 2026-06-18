#!/usr/bin/env bash
# theme.sh — set the wallpaper and recolor the whole desktop from it.
set -euo pipefail

cache="$HOME/.cache/wal"
wall="${1:-$(cat "$cache/wal" 2>/dev/null || true)}"

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

wallust run "$wall"
echo "$wall" > "$cache/wal"

hyprctl reload >/dev/null 2>&1 || true       
killall -SIGUSR2 waybar 2>/dev/null || true
swaync-client --reload-css 2>/dev/null || true
pkill -USR1 -x kitty 2>/dev/null || true
echo "theme.sh: applied $(basename "$wall")"
