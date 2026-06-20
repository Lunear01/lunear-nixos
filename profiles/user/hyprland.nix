# Hyprland desktop home policy: flips on the per-app home modules that make up
# the rice (launcher, bar, notifications, compositor session) plus the Stylix
# target policy for those custom-dotfile apps. The terminal (kitty) comes from
# the lunear.terminal enum. Modules themselves are auto-imported by modules/user.
{ ... }:

{
  lunear.home.rofi.enable = true;
  lunear.home.waybar.enable = true;
  lunear.home.swaync.enable = true;
  lunear.home.hyprland.enable = true;
  lunear.home.stylixTargets.enable = true;
}
