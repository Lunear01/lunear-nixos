{ config, ... }:

{
  imports = [
    ../../modules/user          # auto-imports every user (home) module (all guarded/off)
    ../../profiles/user/base.nix
    ../../profiles/user/desktops/hyprland.nix
  ];

  home.username = "lunear";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";

  # Flatpak (user app list; system service lives in modules/system/desktop/flatpak.nix)
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
