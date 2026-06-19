# nixosSystem factory: wires Home Manager, pins the flake registry, and sets
# the nixPath so the system and `nix run nixpkgs#foo` share one locked nixpkgs.
# Adding a host elsewhere is then a single `mkHost { ... }` call.
inputs:

{ hostname, system ? "x86_64-linux", users ? [] }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs hostname system; };
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
        users = inputs.nixpkgs.lib.genAttrs users
          (u: import ../users/${u}/home.nix);
        backupFileExtension = "backup";
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
