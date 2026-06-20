# nixosSystem factory. Takes a hostname; reads everything else (system, users,
# theme, ...) from hosts/<hostname>/vars.nix and threads it to every module as
# the `systemSettings` specialArg. Per-user vars are loaded from
# users/<user>/vars.nix and exposed to home modules as `userSettings`. Also
# wires Home Manager, pins the flake registry, and sets the nixPath so the system
# and `nix run nixpkgs#foo` share one locked nixpkgs.
#
# flake.nix discovers hosts automatically, so adding a machine is just a new
# hosts/<name>/ dir with a vars.nix — no call to edit here.
inputs:

hostname:

let
  lib = inputs.nixpkgs.lib;
  systemSettings = import ../hosts/${hostname}/vars.nix;
  inherit (systemSettings) system users;
in
lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs systemSettings; };
  modules = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.stylix.nixosModules.stylix
    ../modules/nixos
    ../hosts/${hostname}
    inputs.home-manager.nixosModules.home-manager
    {
      networking.hostName = hostname;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users = lib.genAttrs users (u: {
          imports = [ ../users/${u}/home.nix ];
          _module.args.userSettings = import ../users/${u}/vars.nix;
        });
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs systemSettings; };
        sharedModules = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
      };
      # Pin the registry so `nix run nixpkgs#foo` uses the
      # same locked nixpkgs as the system, not a fresh download.
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    }
  ] ++ map (u: ../users/${u}/default.nix) users;
}
