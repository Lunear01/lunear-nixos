{ ... }:

{
  imports = [
    ../../profiles/nixos/desktops/hyprland.nix
    ./hardware-configuration.nix
  ];

  # Per-install; set once at install time and never bumped.
  system.stateVersion = "26.05";
}
