# Baseline home policy for any user on any machine: shell, dev tooling, and
# host-agnostic programs/packages. Pulls in the shared `themed` helper.
{ pkgs, ... }:

{
  imports = [
    ../../modules/home/lib.nix
    ../../modules/home/shell/bash.nix
    ../../modules/home/dev/default.nix
  ];

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
}
