# Hand the five dynamic apps back to wallust: disable their Stylix targets so the
# wallpaper-derived (theme-blended) palette in ~/.cache/wal/* is the only thing
# coloring them. Everything else Stylix auto-themes stays on, giving the static
# base16 base (selected via lunear.theme.name) across GTK/Qt/Firefox/VSCode/vim/etc.
{ lib, config, ... }:

let
  cfg = config.lunear.home.stylixTargets;
in
{
  options.lunear.home.stylixTargets.enable =
    lib.mkEnableOption "hand the wallust-driven apps back to wallust (disable their Stylix targets)";

  config = lib.mkIf cfg.enable {
    stylix.targets = {
      kitty.enable = false;
      waybar.enable = false;
      rofi.enable = false;
      hyprland.enable = false;
      swaync.enable = false;

      # Firefox is themed statically by Stylix; declare which profile to apply it to.
      firefox.profileNames = [ "default" ];
    };
  };
}
