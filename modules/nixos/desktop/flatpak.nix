{ config, lib, ... }:

let
  cfg = config.lunear.services.flatpak;
in
{
  options.lunear.services.flatpak.enable =
    lib.mkEnableOption "system Flatpak service with the flathub remote";

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      remotes = [{
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }];
    };
  };
}
