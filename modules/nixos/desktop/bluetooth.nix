{ config, lib, ... }:

let
  cfg = config.lunear.desktop.bluetooth;
in
{
  options.lunear.desktop.bluetooth.enable =
    lib.mkEnableOption "Bluetooth (with blueman applet)";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    services.blueman.enable = true;
  };
}
