{ config, lib, ... }:

let
  cfg = config.lunear.home.kitty;
  home = config.home.homeDirectory;
in
{
  options.lunear.home.kitty.enable = lib.mkEnableOption "kitty terminal";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      extraConfig = ''
        include ${home}/.cache/wal/colors-kitty.conf
        dynamic_background_opacity yes
        startup_session ${home}/.config/kitty/session.conf
      '';
    };

    xdg.configFile."kitty/session.conf".source = ./dotfiles/session.conf;
  };
}
