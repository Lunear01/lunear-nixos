{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

 
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "lunear-nixos";
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = false;

  time.timeZone = "America/Toronto";
  time.hardwareClockInLocalTime = true; # Sync Windows dualboot clock

  services.displayManager.gdm.enable = true;

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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";

}

