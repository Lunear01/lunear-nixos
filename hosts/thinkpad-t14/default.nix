{ pkgs, ... }:

{
  imports = [
    ../../profiles/system/desktops/hyprland.nix
    ./hardware-configuration.nix
  ];

  # ── ThinkPad T14-specific system bits ─────────────────────────────────────
  # Battery/thermal management tuned for the laptop.
  services.tlp.enable = true;

  # Host-only system packages.
  environment.systemPackages = with pkgs; [
    # powertop
  ];

  # Per-install; set once at install time and never bumped.
  system.stateVersion = "26.05";
}
