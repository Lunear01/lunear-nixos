# ThinkPad T14 home tweaks. Auto-imported by users/<u>/home.nix when the hostname
# is thinkpad-t14 (it looks for hosts/<hostname>/home.nix). Put host-only user
# packages / program overrides here.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Portable / work extras live here, e.g.:
    # powertop
  ];
}
