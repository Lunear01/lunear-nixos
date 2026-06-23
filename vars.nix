# Shared defaults, threaded to every module as the `settings` arg. flake.nix
# merges hosts/<name>/vars.nix on top, so a host only lists what differs.
# `hostname` is injected by lib/mkHost.nix, not set here.
{
  system = "x86_64-linux";
  theme = "catppuccin-mocha";   # base16 theme; see themes/
  username = "lunear";

  # Per-host display tuning (shared defaults; overridden in hosts/<name>/vars.nix):
  #   monitor    -> primary output (see `hyprctl monitors`)
  #   scale      -> Hyprland fractional scale
  #   cursorSize -> XCURSOR_SIZE / HYPRCURSOR_SIZE
  #   barFontPx  -> waybar font (px)
  #   rofiFontPt -> rofi font (pt)
  monitor = "eDP-1";
  scale = 1.25;
  cursorSize = 18;
  barFontPx = 15;
  rofiFontPt = 11;
}
