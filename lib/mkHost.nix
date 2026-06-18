# nixosSystem factory: wires Home Manager, pins the flake registry, and sets
# the nixPath so the system and `nix run nixpkgs#foo` share one locked nixpkgs.
# Adding a host elsewhere is then a single `mkHost { ... }` call.
inputs:

{ hostname, system ? "x86_64-linux", users ? [] }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ../modules/nixos
    ../hosts/${hostname}
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.lunear = import ../home.nix;
        backupFileExtension = "backup";
        sharedModules = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
      };
      # Pin the registry so `nix run nixpkgs#foo` uses the
      # same locked nixpkgs as the system, not a fresh download.
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    }
  ] ++ map (u: ../users/${u}/default.nix) users;
}
