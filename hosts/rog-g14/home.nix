# ROG G14 home: shared baseline + host-only user packages.
{ pkgs, ... }:

{
  imports = [ ../../common-home.nix ];

  home.packages = with pkgs; [
    # Gaming / GPU-box extras, e.g. mangohud, lutris
    obsidian
  ];
}
