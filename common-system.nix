# Shared system baseline imported by every host's configuration.nix.
# Every module here applies unconditionally — to stop using one, remove its
# import line.
{ ... }:

{
  imports = [
    ./modules/system/boot.nix
    ./modules/system/locale.nix
    ./modules/system/networking.nix
    ./modules/system/nix.nix
    ./modules/system/nix-ld.nix
    ./modules/system/security.nix
    ./modules/system/audio.nix
    ./modules/system/bluetooth.nix
    ./modules/system/graphics.nix
    ./modules/system/portal.nix
    ./modules/system/files.nix
    ./modules/system/flatpak.nix
    ./modules/system/inputmethod.nix
    ./modules/system/hyprland.nix
    ./modules/system/stylix.nix
  ];
}
