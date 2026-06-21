#!/usr/bin/env bash
# cliphist-rofi.sh — card-strip clipboard picker (SUPER+V).
# Cards are 130×130 PNGs with rounded corners, rendered via pango (crisp text).
# Results cached in $XDG_RUNTIME_DIR — instant on repeat opens.
set -euo pipefail

cache_dir="${XDG_RUNTIME_DIR:-/tmp}/cliphist-cards"
mkdir -p "$cache_dir"

# Render at 2× (260px) so rofi downscales to 130px logical — sharp on 1.25× display.
# Font size is also doubled (18pt → 9pt visual) to match.
card_w=260; card_h=260; radius=24; pad=16
bg="#1a1a1a"; fg="#eef3f1"
max_entries=14  # 7 columns; rofi scrolls vertically beyond that

# XML-escape text for pango markup.
pango_escape() {
    printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'
}

make_card() {
    local line="$1"
    local id; id=$(cut -f1 <<< "$line")
    local card="$cache_dir/${id}.png"
    [[ -f "$card" ]] && { printf '%s' "$card"; return; }

    if printf '%s' "$line" | grep -qF '[[ binary'; then
        # Image entry — decode and thumbnail with rounded corners.
        local tmp; tmp="${cache_dir}/${id}_raw.png"
        cliphist decode <<< "$line" \
            | magick - -resize "${card_w}x${card_h}^" -gravity Center \
                -extent "${card_w}x${card_h}" "$tmp" 2>/dev/null \
            && magick "$tmp" \
                \( -size "${card_w}x${card_h}" xc:none \
                   -fill white \
                   -draw "roundrectangle 0,0 $((card_w-1)),$((card_h-1)) ${radius},${radius}" \
                \) \
                -compose DstIn -composite \
                PNG32:"$card" 2>/dev/null \
            && rm -f "$tmp" \
            || magick -size "${card_w}x${card_h}" xc:none \
                -fill "$bg" \
                -draw "roundrectangle 0,0 $((card_w-1)),$((card_h-1)) ${radius},${radius}" \
                PNG32:"$card"
    else
        # Text entry — pango rendering on a rounded background.
        local text inner_w inner_h pango_text
        text=$(cut -f2- <<< "$line" | head -c 300 | tr '\n' ' ')
        pango_text=$(pango_escape "$text")
        inner_w=$(( card_w - pad * 2 ))
        inner_h=$(( card_h - pad * 2 ))

        magick -size "${card_w}x${card_h}" xc:none \
            -fill "$bg" \
            -draw "roundrectangle 0,0 $((card_w-1)),$((card_h-1)) ${radius},${radius}" \
            \( -background none -size "${inner_w}x${inner_h}" \
               pango:"<span font='DejaVu Sans Mono 18' foreground='${fg}'>${pango_text}</span>" \
            \) \
            -gravity NorthWest -geometry "+${pad}+${pad}" \
            -compose Over -composite \
            PNG32:"$card" 2>/dev/null \
            || magick -size "${card_w}x${card_h}" xc:none \
                -fill "$bg" \
                -draw "roundrectangle 0,0 $((card_w-1)),$((card_h-1)) ${radius},${radius}" \
                PNG32:"$card"
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
