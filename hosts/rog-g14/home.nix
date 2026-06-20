# ROG G14 home tweaks. Auto-imported by users/<u>/home.nix when the hostname is
# rog-g14 (it looks for hosts/<hostname>/home.nix). Put host-only user packages
# / program overrides here.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Gaming / GPU-box extras live here, e.g.:
    # mangohud
    # lutris
  ];
}
