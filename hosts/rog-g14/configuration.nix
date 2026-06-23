{ ... }:

{
  imports = [
    ../../common-system.nix
    ./hardware-configuration.nix
  ];

  # asusd: fan curves, keyboard LEDs, power profiles.
  services.asusd.enable = true;

  system.stateVersion = "26.05";
}
