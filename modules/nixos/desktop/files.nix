{ config, lib, ... }:

let
  cfg = config.lunear.desktop.files;
in
{
  options.lunear.desktop.files.enable =
    lib.mkEnableOption "external drive mounting for Nautilus (udisks2 + gvfs)";

  config = lib.mkIf cfg.enable {
    services.udisks2.enable = true;
    services.gvfs.enable = true;
  };
}
