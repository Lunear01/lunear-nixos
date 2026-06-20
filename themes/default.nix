# Theme registry. Each subdirectory here is one self-contained theme that owns
# its palette (colors.yaml) and its Stylix config (default.nix). This aggregator
# auto-discovers them: every dir name becomes a selectable theme, so adding a
# theme is just dropping a new themes/<name>/ folder — nothing to register.
#
# Selected via `theme = "<name>";` in a host or user vars.nix; the lookup happens
# in modules/system/desktop/stylix.nix. The selected base16 palette is the single
# color source for the whole desktop, including the custom-dotfile apps (waybar,
# rofi, swaync, hyprland) which read it via their generated colors files.
{ pkgs }:

# Pure-builtins on purpose: the theme *names* are read by the enum option type in
# modules/system/desktop/stylix.nix, which is evaluated while options are built.
# Touching `pkgs`/`lib` here to compute names would force `pkgs` in that context
# and cause infinite recursion. So names come from readDir alone; `pkgs` is only
# captured lazily inside each theme's value, forced when a theme is selected.
let
  entries = builtins.readDir ./.;
  names = builtins.filter (n: entries.${n} == "directory") (builtins.attrNames entries);
in
builtins.listToAttrs (map (name: {
  inherit name;
  value = import (./. + "/${name}") { inherit pkgs; };
}) names)
