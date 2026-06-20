{ themed, lib, config, ... }:

let
  cfg = config.lunear.home.swaync;
in
{
  options.lunear.home.swaync.enable = lib.mkEnableOption "swaync notification daemon";

  config = lib.mkIf cfg.enable {
    services.swaync = {
      enable = true;
      settings = {
        positionX = "left";
        positionY = "top";
        control-center-positionX = "left";
        control-center-positionY = "top";
      };
    };

    xdg.configFile."swaync/style.css".source = themed ./dotfiles/style.css;
  };
}
