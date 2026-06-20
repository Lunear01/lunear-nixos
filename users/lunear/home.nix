{ config, ... }:

{
  imports = [
    ../../modules/home          # auto-imports every home module (all guarded/off)
    ../../profiles/home/base.nix
    ../../profiles/home/desktops/hyprland.nix
  ];

  home.username = "lunear";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";

  # Flatpak (user app list; system service lives in modules/nixos/desktop/flatpak.nix)
  services.flatpak = {
    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [
      "app.zen_browser.zen"
    ];
  };
}
