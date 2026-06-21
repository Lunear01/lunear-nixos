# Shared home (home-manager) baseline imported by every host's home.nix.
# Every module here applies unconditionally — to stop using one, remove its
# import line. `settings` is an extraSpecialArg (see lib/mkHost.nix);
# palette/paletteRaw/themed come from ./modules/home/palette.nix.
{ pkgs, settings, ... }:

{
  imports = [
    ./modules/home/palette.nix
    ./modules/home/bash.nix
    ./modules/home/dev.nix
    ./modules/home/stylix-targets.nix
    ./modules/home/kitty
    ./modules/home/waybar
    ./modules/home/swaync
    ./modules/home/hyprland
    ./modules/home/rofi
    ./modules/home/fcitx5
  ];

  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";
  home.stateVersion = "26.05";

  programs.fastfetch.enable = true;
  fonts.fontconfig.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Editor: VSCode (program enabled in dev.nix).
  home.sessionVariables.EDITOR = "code --wait";

  # Flatpak remote + Zen browser (system flatpak service is in the system module).
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];
  services.flatpak.packages = [ "app.zen_browser.zen" ];

  home.packages = with pkgs; [
    tree
    wget
    chromium
    wireguard-tools
    proton-vpn
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
  ];
}
