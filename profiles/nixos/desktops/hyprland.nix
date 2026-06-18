# Hyprland desktop policy: the shared desktop baseline plus the compositor.
{ ... }:

{
  imports = [ ../desktop.nix ];

  lunear.desktop.hyprland.enable = true;
}
