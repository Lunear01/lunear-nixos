# Hand the five dynamic apps back to wallust: disable their Stylix targets so the
# wallpaper-derived (Everforest-blended) palette in ~/.cache/wal/* is the only
# thing coloring them. Everything else Stylix auto-themes stays on, giving a
# static Everforest Dark Hard base across GTK/Qt/Firefox/VSCode/vim/etc.
{ ... }:

{
  stylix.targets = {
    kitty.enable = false;
    waybar.enable = false;
    rofi.enable = false;
    hyprland.enable = false;
    swaync.enable = false;

    # Firefox is themed statically by Stylix; declare which profile to apply it to.
    firefox.profileNames = [ "default" ];
  };
}
