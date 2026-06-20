# Choice-based browser: pick one with `browser = "...";` in users/<u>/vars.nix.
# The selected browser's program is enabled; the others stay off. (chromium is
# kept separately in the base profile as a PWA/web-app host.)
{ lib, config, userSettings, ... }:

let
  cfg = config.lunear.browser;
in
{
  options.lunear.browser = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "firefox" "librewolf" ]);
    default = userSettings.browser or "firefox";
    description = "Primary, Stylix-themed web browser.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "firefox") { programs.firefox.enable = true; })
    (lib.mkIf (cfg == "librewolf") { programs.librewolf.enable = true; })
  ];
}
