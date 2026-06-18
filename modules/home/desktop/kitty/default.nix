{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  programs.kitty = {
    enable = true;
    extraConfig = ''
      include ${home}/.cache/wal/colors-kitty.conf
      dynamic_background_opacity yes
      startup_session ${home}/.config/kitty/session.conf
    '';
  };

  xdg.configFile."kitty/session.conf".source = ./dotfiles/session.conf;
}
