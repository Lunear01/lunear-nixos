# Baseline home policy for any user on any machine: enables shell + dev tooling
# and installs host-agnostic programs/packages. The browser/terminal/editor are
# chosen by the lunear.{browser,terminal,editor} enums (default from
# users/<u>/vars.nix). All home modules are auto-imported by modules/home; this
# profile only flips on what the baseline wants.
{ pkgs, ... }:

{
  lunear.home.bash.enable = true;
  lunear.home.dev.enable = true;

  programs.fastfetch.enable = true;

  fonts.fontconfig.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  home.packages = with pkgs; [
    # CLI utilities
    tree
    wget

    # Browser Web app (PWA host; primary browser is the lunear.browser enum)
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
