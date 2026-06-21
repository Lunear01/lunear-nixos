{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  stylix.opacity.terminal = 0.80;

  programs.kitty = {
    enable = true;
    extraConfig = ''
      dynamic_background_opacity yes
      startup_session ${home}/.config/kitty/session.conf
    '';
  };

  xdg.configFile."kitty/session.conf".source = ./dotfiles/session.conf;
}
