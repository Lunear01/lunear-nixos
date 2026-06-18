#!/usr/bin/env bash
# cliphist-rofi.sh — card-strip clipboard picker (SUPER+V).
# Each entry is rendered as a 200×200 card PNG via imagemagick and cached in
# $XDG_RUNTIME_DIR so repeated opens are instant.
set -euo pipefail

cache_dir="${XDG_RUNTIME_DIR:-/tmp}/cliphist-cards"
mkdir -p "$cache_dir"

card_w=200; card_h=200
bg="#1a1a1a"; fg="#eef3f1"
max_entries=63  # 7 columns; rofi scrolls vertically beyond that

# Render (and cache) a preview card for one cliphist list line.
# Prints the path to the PNG.
make_card() {
    local line="$1"
    local id; id=$(cut -f1 <<< "$line")
    local card="$cache_dir/${id}.png"
    [[ -f "$card" ]] && { printf '%s' "$card"; return; }

    if printf '%s' "$line" | grep -qF '[[ binary'; then
        # Image entry — decode and thumbnail.
        cliphist decode <<< "$line" \
            | magick - -resize "${card_w}x${card_h}^" -gravity Center \
                -extent "${card_w}x${card_h}" -background "$bg" "$card" 2>/dev/null \
            || magick -size "${card_w}x${card_h}" xc:"$bg" "$card"
    else
        # Text entry — render wrapped caption.
        local text; text=$(cut -f2- <<< "$line" | head -c 400)
        magick -size "${card_w}x${card_h}" \
            -background "$bg" \
            -fill "$fg" \
            -font "DejaVu-Sans-Mono" \
            -pointsize 11 \
            caption:"$text" \
            "$card" 2>/dev/null \
            || magick -size "${card_w}x${card_h}" xc:"$bg" "$card"
    fi

    printf '%s' "$card"
}

mapfile -t lines < <(cliphist list | head -n "$max_entries")
[[ ${#lines[@]} -gt 0 ]] || { notify-send "Clipboard is empty" 2>/dev/null; exit 0; }

entries=""
for line in "${lines[@]}"; do
    display=$(cut -f2- <<< "$line" | tr '\n' ' ')
    card=$(make_card "$line")
    entries+="${display}\0icon\x1f${card}\n"
done

idx=$(printf '%b' "$entries" \
    | rofi -dmenu -i -p "" \
        -show-icons \
        -format i \
        -theme "$HOME/.config/rofi/cliphist.rasi") || exit 0

[[ -n "$idx" ]] || exit 0
printf '%s' "${lines[$idx]}" | cliphist decode | wl-copy
