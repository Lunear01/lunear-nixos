{ themed, lib, config, ... }:

let
  cfg = config.lunear.home.waybar;
in
{
  options.lunear.home.waybar.enable = lib.mkEnableOption "waybar status bar";

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    systemd.user.services.waybar = {
      Unit.StartLimitIntervalSec = 0;
      Service = {
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    xdg.configFile = {
      "waybar/config.jsonc".source = ./dotfiles/config.jsonc;
      "waybar/style.css".source = themed ./dotfiles/style.css;
    };
  };
}
