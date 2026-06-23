{ ... }:

{
  imports = [
    ../../common-system.nix
    ./hardware-configuration.nix
  ];

  # tlp: battery/thermal management for the laptop.
  services.tlp.enable = true;

  system.stateVersion = "26.05";
}
