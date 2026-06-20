# Choice-based browser: pick one with `browser = "...";` in vars.nix.
# The selected browser's program is enabled; the others stay off. (chromium is
# kept separately in the base profile as a PWA/web-app host.)
{ lib, config, settings, ... }:

let
  cfg = config.lunear.browser;
in
{
  options.lunear.browser = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "firefox" "librewolf" "zen" ]);
    default = settings.browser or "firefox";
    description = "Primary web browser. firefox/librewolf are Stylix-themed nix programs; zen ships as a Flathub flatpak (needs the flathub remote from home.nix).";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "firefox") { programs.firefox.enable = true; })
    (lib.mkIf (cfg == "librewolf") { programs.librewolf.enable = true; })
    (lib.mkIf (cfg == "zen") { services.flatpak.packages = [ "app.zen_browser.zen" ]; })
  ];
}
