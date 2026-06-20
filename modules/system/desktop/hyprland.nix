{ config, lib, ... }:

let
  cfg = config.lunear.desktop.hyprland;
in
{
  options.lunear.desktop.hyprland.enable =
    lib.mkEnableOption "Hyprland compositor with GDM";

  config = lib.mkIf cfg.enable {
    services.displayManager.gdm.enable = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
