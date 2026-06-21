{ pkgs, palette, settings, ... }:

let
  # Per-host bar font size: GTK CSS has no numeric variables, so substitute the
  # @barFontPx@ placeholder in style.css at build time from `settings`.
  styleCss = pkgs.writeText "waybar-style.css"
    (builtins.replaceStrings [ "@barFontPx@" ] [ (toString settings.barFontPx) ]
      (builtins.readFile ./dotfiles/style.css));

  # Raw base16 palette in waybar's @-name vocabulary; style.css maps these onto
  # semantic names and @import-s this file (same dir, so a relative import works).
  colorsCss = pkgs.writeText "colors-waybar.css" ''
    @define-color foreground ${palette.foreground};
    @define-color background ${palette.background};
    @define-color cursor     ${palette.cursor};

    @define-color color0  ${palette.color0};
    @define-color color1  ${palette.color1};
    @define-color color2  ${palette.color2};
    @define-color color3  ${palette.color3};
    @define-color color4  ${palette.color4};
    @define-color color5  ${palette.color5};
    @define-color color6  ${palette.color6};
    @define-color color7  ${palette.color7};
    @define-color color8  ${palette.color8};
    @define-color color9  ${palette.color9};
    @define-color color10 ${palette.color10};
    @define-color color11 ${palette.color11};
    @define-color color12 ${palette.color12};
    @define-color color13 ${palette.color13};
    @define-color color14 ${palette.color14};
    @define-color color15 ${palette.color15};
  '';
in
{
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
    "waybar/colors.css".source = colorsCss;
    "waybar/style.css".source = styleCss;
  };
}
