# Exposes `themed` and the Stylix-derived color `palette` to every home module via
# _module.args.
#
# `themed` copies a repo dotfile into the store, substituting @home@ with the real
# home directory so nothing hardcodes a username/path.
#
# `palette` / `paletteRaw` are the standard base16 -> 16-color terminal mapping,
# built from the selected Stylix theme (`config.lib.stylix.colors`). They are the
# single color source for the custom-dotfile desktop apps (waybar, swaync, rofi,
# hyprland) now that wallust is gone. Both are lazy `_module.args`, so they are
# only forced by the desktop modules that consume them — which are only enabled
# alongside Stylix — keeping non-Stylix hosts unaffected.
#   palette    -> "#rrggbb"  (CSS / rasi)
#   paletteRaw -> "rrggbb"   (Hyprland rgba(RRGGBBAA))
{ config, pkgs, ... }:

let
  mkPalette = withHash:
    let
      c = if withHash
          then config.lib.stylix.colors.withHashtag
          else config.lib.stylix.colors;
    in {
      background = c.base00;
      foreground = c.base05;
      cursor     = c.base05;

      color0  = c.base00;
      color1  = c.base08;
      color2  = c.base0B;
      color3  = c.base0A;
      color4  = c.base0D;
      color5  = c.base0E;
      color6  = c.base0C;
      color7  = c.base05;
      color8  = c.base03;
      color9  = c.base08;
      color10 = c.base0B;
      color11 = c.base0A;
      color12 = c.base0D;
      color13 = c.base0E;
      color14 = c.base0C;
      color15 = c.base07;
    };
in
{
  _module.args = {
    themed = src: pkgs.replaceVars src { home = config.home.homeDirectory; };
    palette = mkPalette true;
    paletteRaw = mkPalette false;
  };
}
