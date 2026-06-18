#!/usr/bin/env bash
# wallpaper-picker.sh — 3x3 image-preview grid via rofi.
# Bound to SUPER+SHIFT+W in hypr/hyprland.lua.
set -euo pipefail

dir="$HOME/wallpapers"
[[ -d "$dir" ]] || { notify-send "No ~/wallpapers directory" 2>/dev/null; exit 1; }

mapfile -d '' -t files < <(find "$dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) -print0 | sort -z)
[[ ${#files[@]} -gt 0 ]] || { notify-send "No wallpapers in $dir" 2>/dev/null; exit 1; }

# Each entry: "basename\0icon\x1f/full/path" — rofi renders the image as thumbnail.
entries=""
for f in "${files[@]}"; do
    entries+="$(basename "$f")\0icon\x1f${f}\n"
done

choice="$(printf '%b' "$entries" \
    | rofi -dmenu -i -p "" \
        -show-icons \
        -theme "$HOME/.config/rofi/wallpaper.rasi")"
[[ -n "$choice" ]] || exit 0

exec "$HOME/.config/hypr/scripts/theme.sh" "$dir/$choice"
