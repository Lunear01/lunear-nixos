{ config, lib, ... }:

let
  cfg = config.lunear.home.kitty;
  home = config.home.homeDirectory;
in
{
  options.lunear.home.kitty.enable = lib.mkEnableOption "kitty terminal";

  config = lib.mkIf cfg.enable {
    # Colors come from Stylix's native kitty target (on by default), themed from
    # the selected base16 scheme. The translucent (liquid-glass) background is the
    # only extra: Stylix drives the opacity via stylix.opacity.terminal, frosted
    # by Hyprland's window blur.
    stylix.opacity.terminal = 0.80;

    programs.kitty = {
      enable = true;
      extraConfig = ''
        dynamic_background_opacity yes
        startup_session ${home}/.config/kitty/session.conf
      '';
    };

    xdg.configFile."kitty/session.conf".source = ./dotfiles/session.conf;
  };
}
