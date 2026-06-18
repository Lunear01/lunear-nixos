# Hyprland desktop home policy: pulls in the per-app home modules that make up
# the rice (terminal, launcher, bar, notifications, compositor session).
{ ... }:

{
  imports = [
    ../../../modules/home/desktop/kitty/default.nix
    ../../../modules/home/desktop/rofi/default.nix
    ../../../modules/home/desktop/waybar/default.nix
    ../../../modules/home/desktop/swaync/default.nix
    ../../../modules/home/desktop/hyprland/default.nix
  ];
}
