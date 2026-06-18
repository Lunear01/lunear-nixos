{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "lunear-nixos";
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = false; # ProtonVPN

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  time.timeZone = "America/Toronto";
  time.hardwareClockInLocalTime = true; # Sync Windows dualboot clock

  services.displayManager.gdm.enable = true;
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.udisks2.enable = true; # External drive mounting
  services.gvfs.enable = true;    # Nautilus backend

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  users.users.lunear = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-generations +3";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}
