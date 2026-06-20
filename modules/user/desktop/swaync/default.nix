{ pkgs, palette, lib, config, ... }:

let
  cfg = config.lunear.home.swaync;

  # swaync's semantic palette, from the selected Stylix base16 theme. style.css
  # @import-s this file (same dir, so a relative import works). surface is a card
  # tone one step lighter than the background (base02).
  colorsCss = pkgs.writeText "colors-swaync.css" ''
    @define-color foreground ${palette.foreground};
    @define-color background ${palette.background};
    @define-color accent     ${palette.color4};
    @define-color accent-alt  ${palette.color2};
    @define-color urgent      ${palette.color1};
    @define-color surface     ${config.lib.stylix.colors.withHashtag.base02};
  '';
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

    xdg.configFile = {
      "swaync/colors.css".source = colorsCss;
      "swaync/style.css".source = ./dotfiles/style.css;
    };
  };
}
