{ pkgs, ... }:

{
  imports = [
    ../../profiles/system/hyprland.nix
    ./hardware-configuration.nix
  ];

  # ── ROG G14-specific system bits ──────────────────────────────────────────
  # asusd: fan curves, keyboard LEDs, power profiles for ASUS laptops.
  services.asusd.enable = true;

  # Host-only system packages.
  environment.systemPackages = with pkgs; [
    # asusctl   # CLI for asusd (uncomment if you want the tool too)
  ];

  # Per-install; set once at install time and never bumped.
  system.stateVersion = "26.05";
}
