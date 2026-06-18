{ config, lib, pkgs, ... }:

let
  cfg = config.lunear.desktop.portal;
in
{
  options.lunear.desktop.portal.enable =
    lib.mkEnableOption "xdg-desktop-portal (needed for Flatpak)";

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
