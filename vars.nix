# Single source of truth for this NixOS config. Threaded to every module as the
# `settings` arg: a specialArg for system modules, and per-user `_module.args`
# for home modules (each user also gets its own `username`). `hostname` is
# derived from the host directory name in lib/mkHost.nix, so it is not set here.
#
# Multi-host: this file holds the shared defaults. A host may override any field
# by dropping a partial attrset in hosts/<name>/vars.nix (merged on top).
{
  system = "x86_64-linux";
  users = [ "lunear" ];

  # Stylix base16 theme (see themes/).
  theme = "catppuccin-mocha";

  # Primary user.
  username = "lunear";

  # Per-host display tuning. These are the shared defaults; each machine
  # overrides what differs in hosts/<name>/vars.nix.
  #   monitor    -> primary output name (see `hyprctl monitors`)
  #   scale      -> Hyprland fractional scale for that output
  #   cursorSize -> XCURSOR_SIZE / HYPRCURSOR_SIZE
  #   barFontPx  -> waybar font size (px)
  #   rofiFontPt -> rofi font size (pt)
  monitor = "eDP-1";
  scale = 1.25;
  cursorSize = 18;
  barFontPx = 15;
  rofiFontPt = 11;
}
