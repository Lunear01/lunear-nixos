{ pkgs, ... }:

{
  # Needed for Flatpak
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
