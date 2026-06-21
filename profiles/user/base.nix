{ pkgs, ... }:

{
  programs.fastfetch.enable = true;
  fonts.fontconfig.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Editor: VSCode (program enabled in the dev module).
  home.sessionVariables.EDITOR = "code --wait";

  # Browser: Zen, shipped as a Flathub flatpak (remote declared in home.nix).
  services.flatpak.packages = [ "app.zen_browser.zen" ];

  home.packages = with pkgs; [
    # CLI utilities
    tree
    wget

    # Browser web-app host (PWA host; primary browser is Zen above)
    chromium

    # VPN / networking
    wireguard-tools
    proton-vpn

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
  ];
}
