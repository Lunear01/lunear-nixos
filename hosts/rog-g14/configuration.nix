{ pkgs, ... }:

{
  imports = [
    ../../common-system.nix
    ./hardware-configuration.nix
  ];

  # ROG G14-specific: asusd (fan curves, keyboard LEDs, power profiles).
  services.asusd.enable = true;

  environment.systemPackages = with pkgs; [
    # asusctl
  ];

  system.stateVersion = "26.05";
}
