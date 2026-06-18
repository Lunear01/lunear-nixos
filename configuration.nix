{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "lunear-nixos";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
     # ProtonVPN requirement
    checkReversePath = false;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

   # GPU acceleration for Wayland
  hardware.graphics.enable = true;

  time.timeZone = "America/Toronto";

  # Sync Windows dualboot clock
  time.hardwareClockInLocalTime = true; 

  # Desktop privilege escalation
  security.polkit.enable = true;

  # Real-time scheduling for PipeWire
  security.rtkit.enable = true;   

  services.displayManager.gdm.enable = true;
  services.blueman.enable = true;
  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Needed for Flatpak
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # External drive mounting for Nautilus
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Run unpatched binaries (npm, claude-code, etc.)
  programs.nix-ld.enable = true;

  users.users.lunear = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    
    # Flakes only
    channel.enable = false;

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-generations +3";
    };

    # Periodic store deduplication
    optimise.automatic = true; 

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      # Wheel users can use nix without sudo
      trusted-users = [ "root" "@wheel" ];  
    };
  };

  system.stateVersion = "26.05";
}
