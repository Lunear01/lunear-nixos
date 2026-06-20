{ config, settings, lib, hostname, ... }:

let
  # Per-host home tweaks (extra packages, app overrides). Auto-imported when
  # hosts/<hostname>/home.nix exists, so everything about a machine lives in one
  # dir. `hostname` is a specialArg (not the config-time `settings`), so it is
  # safe to use here in `imports` without infinite recursion.
  hostProfile = ../../hosts/${hostname}/home.nix;
in
{
  imports = [
    ../../modules/user          # auto-imports every user (home) module (all guarded/off)
    ../../profiles/user/base.nix
    ../../profiles/user/hyprland.nix
  ] ++ lib.optional (builtins.pathExists hostProfile) hostProfile;

  home.username = settings.username;
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";

  # Flatpak remote (system service lives in modules/system/desktop/flatpak.nix).
  # Per-app flatpaks are declared by the modules that own them (e.g. the zen
  # browser flatpak lives in modules/user/apps/browser).
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];
}
