{ config, settings, ... }:

{
  imports = [
    ../../modules/user          # auto-imports every user (home) module (all guarded/off)
    ../../profiles/user/base.nix
    ../../profiles/user/desktops/hyprland.nix
  ];

  home.username = settings.username;
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";

  # Flatpak remote (system service lives in modules/system/desktop/flatpak.nix).
  # Per-app flatpaks are declared by the modules that own them (e.g. the zen
  # browser flatpak lives in modules/user/apps/browser).
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];
}
