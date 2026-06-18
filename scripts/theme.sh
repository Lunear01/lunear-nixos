#!/usr/bin/env bash
# theme.sh — set the wallpaper and recolor the whole desktop from it.
#
#   theme.sh /path/to/image.jpg   set this wallpaper + regenerate colors
#   theme.sh                      re-apply the last wallpaper (e.g. at login)
#
# Pipeline: awww (wallpaper) → wallust (palette → ~/.cache/wal/*) → reload apps.
# Deployed live via Home Manager out-of-store symlink, so edits apply at once.
set -euo pipefail

cache="$HOME/.cache/wal"
wall="${1:-$(cat "$cache/wal" 2>/dev/null || true)}"

if [[ -z "$wall" || ! -f "$wall" ]]; then
    echo "theme.sh: no valid wallpaper (got: '${wall:-<none>}')" >&2
    echo "usage: theme.sh /path/to/image" >&2
    exit 1
fi

mkdir -p "$cache"

# 1. Wallpaper — start the awww daemon if it isn't already up.
if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    sleep 0.5
fi
awww img "$wall" --transition-type grow --transition-pos 0.9,0.1 --transition-fps 60

# 2. Palette — wallust writes every template target under ~/.cache/wal/.
wallust run "$wall"
echo "$wall" > "$cache/wal"

# 3. Reload the apps that don't watch their color files themselves.
hyprctl reload >/dev/null 2>&1 || true                 # hyprland (reads colors-hyprland.lua)
killall -SIGUSR2 waybar 2>/dev/null || true            # waybar (@imports colors-waybar.css)
swaync-client --reload-css 2>/dev/null || true         # swaync (@imports colors-swaync.css)
# kitty: open windows recolor live via wallust's escape sequences; also nudge
# any running instances to re-read their config (picks up the include).
pkill -USR1 -x kitty 2>/dev/null || true
# rofi needs no reload — it reads its theme fresh on each launch.

echo "theme.sh: applied $(basename "$wall")"
