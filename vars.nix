# Shared settings for this NixOS config. Threaded to every module as the
# `settings` arg: a specialArg for system modules, and an extraSpecialArg for
# home modules. `hostname` is NOT set here — lib/mkHost.nix injects it from the
# host name passed in flake.nix.
#
# Multi-host: this file holds the shared defaults. flake.nix merges a host's
# hosts/<name>/vars.nix on top (shared // host overrides), so a host only needs
# to list the fields that differ.
{
  system = "x86_64-linux";

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
