# Self-contained theme: owns its base16 palette (./colors.yaml) and its Stylix
# config. The attrs returned here are merged into `stylix` (see
# modules/system/desktop/stylix.nix), so a theme may also override cursor/fonts/
# icons by adding those keys — the shared defaults are mkDefault.
{ pkgs }:

{
  polarity = "dark";
  base16Scheme = ./colors.yaml;
}
