{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

 
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "lunear-nixos";
  networking.networkmanager.enable = true;

  # ProtonVPN Tweak
  networking.firewall.checkReversePath = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  time.timeZone = "America/Toronto";
  time.hardwareClockInLocalTime = true; # Sync Windows dualboot clock

  services.displayManager.gdm.enable = true;

  # Allow Nautilus to detect and mount external drives
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  programs.hyprland = {
      enable = true;
      xwayland.enable = true;
  };

  users.users.lunear = {
     isNormalUser = true;
     extraGroups = ["networkmanager" "wheel" ];
     packages = with pkgs; [
       tree
     ];
   };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
     vim
     wget
     awww
     hyprshell
     nautilus
     wireguard-tools
     proton-vpn
     wl-clipboard
     libnotify
     pavucontrol
     brightnessctl
     overskride
     claude-code
   ];

  # Automatic Generation Clean up, keeping only most recent 3 generations
  nix.gc = {
  automatic = true;
  dates = "daily";
  options = "--delete-generations +3";
};


  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";

}

