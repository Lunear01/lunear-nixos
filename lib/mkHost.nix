# nixosSystem factory. Takes a hostname; reads the single source of truth from
# the repo-root vars.nix, derives `hostname` from this arg, and overlays an
# optional per-host hosts/<hostname>/vars.nix (partial overrides). The merged
# result is threaded to every module as the `settings` arg: a specialArg for
# system modules, and per-user `_module.args.settings` (with that user's
# `username`) for home modules. Also wires Home Manager, pins the flake
# registry, and sets the nixPath so the system and `nix run nixpkgs#foo` share
# one locked nixpkgs.
#
# flake.nix discovers hosts automatically, so adding a machine is just a new
# hosts/<name>/ dir (with an optional vars.nix to override the root defaults) —
# no call to edit here.
inputs:

hostname:

let
  lib = inputs.nixpkgs.lib;
  baseSettings = import ../vars.nix;
  hostFile = ../hosts/${hostname}/vars.nix;
  hostSettings = lib.optionalAttrs (builtins.pathExists hostFile) (import hostFile);
  settings = baseSettings // { inherit hostname; } // hostSettings;
  inherit (settings) system users;
in
lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs settings; };
  modules = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.stylix.nixosModules.stylix
    ../modules/system
    ../hosts/${hostname}
    inputs.home-manager.nixosModules.home-manager
    {
      networking.hostName = hostname;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users = lib.genAttrs users (u: {
          imports = [ ../users/${u}/home.nix ];
          _module.args.settings = settings // { username = u; };
        });
        backupFileExtension = "backup";
        # hostname is a specialArg (available during `imports`, unlike the
        # config-time `settings` _module.arg) so home.nix can pick a per-host
        # profile without triggering infinite recursion.
        extraSpecialArgs = { inherit inputs hostname; };
        sharedModules = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
      };
      # Pin the registry so `nix run nixpkgs#foo` uses the
      # same locked nixpkgs as the system, not a fresh download.
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    }
  ] ++ map (u: ../users/${u}/default.nix) users;
}
