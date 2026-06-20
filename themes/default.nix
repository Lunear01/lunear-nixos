# Named base16 themes for the Stylix base layer (GTK/Qt/Firefox/VSCode/console).
# Select one with `theme = "<name>";` in a host or user vars.nix. This only
# re-skins the static Stylix layer — the wallust-driven apps (kitty/waybar/rofi/
# swaync/hyprland) keep recoloring per-wallpaper, untouched by this choice.
#
# Add a theme: pick any scheme shipped by pkgs.base16-schemes
# (`ls ${pkgs.base16-schemes}/share/themes`) and add a name → attrs entry.
{ pkgs }:

let
  scheme = name: "${pkgs.base16-schemes}/share/themes/${name}.yaml";
in
{
  "everforest-dark-hard"   = { polarity = "dark"; base16Scheme = scheme "everforest-dark-hard"; };
  "everforest-dark-medium" = { polarity = "dark"; base16Scheme = scheme "everforest-dark-medium"; };
  "gruvbox-dark-hard"      = { polarity = "dark"; base16Scheme = scheme "gruvbox-dark-hard"; };
  "gruvbox-dark-medium"    = { polarity = "dark"; base16Scheme = scheme "gruvbox-dark-medium"; };
  "catppuccin-mocha"       = { polarity = "dark"; base16Scheme = scheme "catppuccin-mocha"; };
  "tokyo-night-dark"       = { polarity = "dark"; base16Scheme = scheme "tokyo-night-dark"; };
  "kanagawa"               = { polarity = "dark"; base16Scheme = scheme "kanagawa"; };
  "rose-pine"              = { polarity = "dark"; base16Scheme = scheme "rose-pine"; };
  "nord"                   = { polarity = "dark"; base16Scheme = scheme "nord"; };
  "dracula"                = { polarity = "dark"; base16Scheme = scheme "dracula"; };
}
