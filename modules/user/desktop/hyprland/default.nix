{ pkgs, paletteRaw, lib, config, ... }:

let
  cfg = config.lunear.home.hyprland;

  # Hyprland border palette in rgba(RRGGBBAA) form, from the selected Stylix
  # base16 theme. hyprland.lua dofile()s this over its built-in fallback palette.
  colorsLua = pkgs.writeText "colors-hyprland.lua" ''
    -- Generated from the Stylix palette by hyprland/default.nix.
    return {
        foreground = "rgba(${paletteRaw.foreground}ff)",
        background = "rgba(${paletteRaw.background}ff)",
        color0  = "rgba(${paletteRaw.color0}ff)",
        color1  = "rgba(${paletteRaw.color1}ff)",
        color2  = "rgba(${paletteRaw.color2}ff)",
        color3  = "rgba(${paletteRaw.color3}ff)",
        color4  = "rgba(${paletteRaw.color4}ff)",
        color5  = "rgba(${paletteRaw.color5}ff)",
        color6  = "rgba(${paletteRaw.color6}ff)",
        color7  = "rgba(${paletteRaw.color7}ff)",
        color8  = "rgba(${paletteRaw.color8}ff)",
        color9  = "rgba(${paletteRaw.color9}ff)",
        color10 = "rgba(${paletteRaw.color10}ff)",
        color11 = "rgba(${paletteRaw.color11}ff)",
        color12 = "rgba(${paletteRaw.color12}ff)",
        color13 = "rgba(${paletteRaw.color13}ff)",
        color14 = "rgba(${paletteRaw.color14}ff)",
        color15 = "rgba(${paletteRaw.color15}ff)",
    }
  '';
in
{
  options.lunear.home.hyprland.enable =
    lib.mkEnableOption "Hyprland session: Stylix theming, dotfiles, and helper tools";

  config = lib.mkIf cfg.enable {
    services.cliphist.enable = true;
    services.playerctld.enable = true;

    home.packages = with pkgs; [
      # Desktop / Wayland
      awww
      hyprshell
      hyprshot
      nautilus
      wl-clipboard
      imagemagick
      libnotify
      pavucontrol
      brightnessctl
      overskride
    ];

    # Session target
    systemd.user.targets.hyprland-session = {
      Unit = {
        Description = "Hyprland compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Before = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    # Dotfiles
    xdg.configFile = {
      "hypr/hyprland.lua".source = ./dotfiles/hypr/hyprland.lua;

      # Border palette from the selected Stylix base16 theme; dofile()d by hyprland.lua.
      "hypr/colors-hyprland.lua".source = colorsLua;

      # Scripts are exec'd directly (see hypr/hyprland.lua), so keep +x.
      "hypr/scripts/theme.sh" = {
        source = ./dotfiles/scripts/theme.sh;
        executable = true;
      };
      "hypr/scripts/wallpaper-picker.sh" = {
        source = ./dotfiles/scripts/wallpaper-picker.sh;
        executable = true;
      };
      "hypr/scripts/cliphist-rofi.sh" = {
        source = ./dotfiles/scripts/cliphist-rofi.sh;
        executable = true;
      };
    };
  };
}
