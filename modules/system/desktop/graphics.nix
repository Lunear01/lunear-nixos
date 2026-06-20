{ config, lib, ... }:

let
  cfg = config.lunear.desktop.graphics;
in
{
  options.lunear.desktop.graphics.enable =
    lib.mkEnableOption "GPU acceleration for Wayland";

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;
  };
}
