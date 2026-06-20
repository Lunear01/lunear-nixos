# kitty is themed by Stylix's native target. waybar/rofi/swaync/hyprland keep
# their own custom (liquid-glass) dotfiles, which are re-sourced from the Stylix
# base16 palette by their modules — so their Stylix targets stay OFF here to
# avoid double-defining the same config files. Everything else Stylix auto-themes
# stays on, giving the base16 theme (selected via lunear.theme.name) across
# GTK/Qt/Firefox/VSCode/vim/etc.
{ lib, config, ... }:

let
  cfg = config.lunear.home.stylixTargets;
in
{
  options.lunear.home.stylixTargets.enable =
    lib.mkEnableOption "Stylix target policy for the custom-dotfile desktop apps";

  config = lib.mkIf cfg.enable {
    stylix.targets = {
      # These apps own their config files via xdg.configFile/programs.*; enabling
      # the matching Stylix target would double-define them. Colors instead come
      # from the Stylix palette via each module's generated colors file.
      waybar.enable = false;
      rofi.enable = false;
      hyprland.enable = false;
      swaync.enable = false;

      # Firefox is themed statically by Stylix; declare which profile to apply it to.
      firefox.profileNames = [ "default" ];
    };
  };
}
