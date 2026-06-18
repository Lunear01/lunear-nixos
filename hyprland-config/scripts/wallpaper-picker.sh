#!/usr/bin/env bash
# wallpaper-picker.sh — pick a wallpaper from ~/wallpapers via rofi, then theme.
# Bound to SUPER+SHIFT+W in hypr/hyprland.lua.
set -euo pipefail

dir="$HOME/wallpapers"
[[ -d "$dir" ]] || { notify-send "No ~/wallpapers directory" 2>/dev/null; exit 1; }

# List image files (newline-separated, basenames shown to the user).
mapfile -d '' -t files < <(find "$dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) -print0)
[[ ${#files[@]} -gt 0 ]] || { notify-send "No wallpapers in $dir" 2>/dev/null; exit 1; }

choice="$(for f in "${files[@]}"; do basename "$f"; done \
    | rofi -dmenu -i -p "Wallpaper" -theme-str 'window {width: 25%;}')"
[[ -n "$choice" ]] || exit 0

exec "$HOME/.config/hypr/scripts/theme.sh" "$dir/$choice"
