{ themed, lib, config, ... }:

let
  cfg = config.lunear.home.rofi;
in
{
  options.lunear.home.rofi.enable = lib.mkEnableOption "rofi launcher";

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      theme = "${themed ./dotfiles/theme.rasi}";
    };

    xdg.configFile = {
      "rofi/wallpaper.rasi".source = themed ./dotfiles/wallpaper.rasi;
      "rofi/cliphist.rasi".source = themed ./dotfiles/cliphist.rasi;
    };
  };
}
