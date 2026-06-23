# Exposes `themed`, `palette`, and `paletteRaw` to every home module via
# _module.args (lazy — only forced by the desktop modules that consume them).
#
#   themed     -> copies a dotfile into the store, filling @home@ with the real home dir
#   palette    -> base16 -> 16-color map, "#rrggbb"  (CSS / rasi)
#   paletteRaw -> same, "rrggbb"   (Hyprland rgba(RRGGBBAA))
#
# palette/paletteRaw are the single color source for the custom-dotfile apps
# (waybar, swaync, rofi, hyprland), built from the selected Stylix theme.
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
