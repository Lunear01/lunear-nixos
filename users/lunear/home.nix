{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/lib.nix
    ../../modules/home/shell/bash.nix
    ../../modules/home/dev/default.nix
    ../../modules/home/desktop/kitty/default.nix
    ../../modules/home/desktop/rofi/default.nix
    ../../modules/home/desktop/waybar/default.nix
    ../../modules/home/desktop/swaync/default.nix
    ../../modules/home/desktop/hyprland/default.nix
  ];

  home.username = "lunear";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.fastfetch.enable = true;
  programs.firefox.enable = true;
  programs.vim.enable = true;

  fonts.fontconfig.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  home.packages = with pkgs; [
    # CLI utilities
    tree
    wget

    # Browser Web app
    chromium

    # VPN / networking
    wireguard-tools
    proton-vpn

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

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
