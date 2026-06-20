# Action plan — Remove wallust, Stylix-only theming

## Goal
Drop wallust entirely. Stylix's selected base16 theme (`lunear.theme.name`) becomes the
single color source for the whole desktop, including the 5 formerly wallust-driven apps
(kitty, waybar, rofi, swaync, hyprland). Wallpaper switching (awww + picker) is kept; it
just no longer drives colors.

## Decisions (confirmed with user)
- **Color source:** Stylix is the authority. kitty → true Stylix native target. waybar /
  rofi / swaync / hyprland → keep their custom liquid-glass designs but re-source colors
  from Stylix's base16 palette (`config.lib.stylix.colors`) instead of wallust's cache.
- **Wallpaper:** keep awww + wallpaper-picker; remove only the `wallust run` recolor step.

## Mechanism
The wallust templates already blended each slot toward its base16 anchor, so the static
base16 palette reproduces every color name. Add a shared `palette` helper in
`modules/user/lib.nix` exposing the standard base16→16-color mapping from
`config.lib.stylix.colors` (lazy `_module.args`, only forced by the desktop modules that
use it, which are only enabled alongside Stylix):

    bg=base00 fg=base05 cursor=base05
    color0=base00 1=base08 2=base0B 3=base0A 4=base0D 5=base0E 6=base0C 7=base05
    color8=base03 9=base08 10=base0B 11=base0A 12=base0D 13=base0E 14=base0C 15=base07

Expose `palette` (#rrggbb, for css/rasi) and `paletteRaw` (rrggbb, for hyprland rgba).

## Per-app changes
- **kitty** (`modules/user/desktop/kitty/default.nix`): remove the
  `include ~/.cache/wal/colors-kitty.conf` line; keep `dynamic_background_opacity yes` +
  session; opacity via `stylix.opacity.terminal = 0.80`. Let `stylix.targets.kitty` (on by
  default) theme it natively.
- **waybar**: generate `~/.config/waybar/colors.css` from `palette`; change style.css
  import from the wallust cache to `@import "colors.css";`; drop the wallust contrast hacks
  (base16 is fixed/legible) — map `accent`→color4 directly, etc.
- **swaync**: generate `~/.config/swaync/colors.css` (foreground/background/accent/
  accent-alt/urgent/surface); change style.css import to `@import "colors.css";`.
- **rofi**: generate `~/.config/rofi/colors.rasi` (background/-alt/foreground/selected/
  active/urgent + glass/glass-alt/glass-sheen/glass-sel with alpha suffixes). theme.rasi is
  loaded from the store, so import via absolute `@home@/.config/rofi/colors.rasi` (keep
  `themed`). Repoint wallpaper.rasi + cliphist.rasi imports the same way.
- **hyprland** (`modules/user/desktop/hyprland/`): generate `~/.config/hypr/colors-hyprland.lua`
  (rgba(RRGGBBAA) from `paletteRaw`); change the `dofile` path in hyprland.lua from the
  wallust cache to `~/.config/hypr/colors-hyprland.lua`. Remove the `wallust` package, the
  `wallust/wallust.toml` + `wallust/templates` configFile entries, and delete the
  `dotfiles/wallust/` dir. Update the module option description.

## Stylix target module (`modules/user/desktop/stylix.nix`)
Remove `kitty.enable = false;` (let it theme kitty). Keep waybar/rofi/swaync/hyprland
targets OFF (their custom dotfiles own the files; enabling the Stylix targets would
double-define the config files). Keep `firefox.profileNames`. Update comments.

## Scripts
- `scripts/theme.sh`: keep awww wallpaper set + record; remove `wallust run` and the
  per-app color-reload signals (colors are static now). hyprland.lua autostart comment.

## Docs / comments
Update wallust references in: `modules/system/desktop/stylix.nix`, `themes/default.nix`,
`profiles/user/desktops/hyprland.nix`, `modules/user/desktop/stylix.nix`, `README.md`.
Create/refresh ROADMAP.md note.

## Verify
`nix build .#nixosConfigurations.lunear-nixos.config.system.build.toplevel` (no root) to
confirm the whole system + Home Manager evaluates and builds. Grep to confirm zero
`wallust` / `.cache/wal` references remain.
