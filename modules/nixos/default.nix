# Blanket-imports every NixOS module. core/* always applies; desktop/* is
# option-guarded (lunear.desktop.*, default off) so importing the whole tree
# is safe even for a host that wants none of it (e.g. a future server).
{ ... }:

{
  imports = [
    ./core/boot.nix
    ./core/networking.nix
    ./core/locale.nix
    ./core/security.nix
    ./core/nix-ld.nix
    ./core/nix.nix

    ./desktop/audio.nix
    ./desktop/bluetooth.nix
    ./desktop/graphics.nix
    ./desktop/portal.nix
    ./desktop/files.nix
    ./desktop/flatpak.nix
    ./desktop/hyprland.nix
    ./desktop/stylix.nix
  ];
}
