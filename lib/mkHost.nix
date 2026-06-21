# nixosSystem factory. Takes a hostname and the merged settings; injects
# `hostname` into settings, threads `settings` to every module (system as a
# specialArg, home via extraSpecialArgs), and wires home-manager for the one
# user. flake.nix lists hosts explicitly and does the vars merge.
{ inputs }:

{ hostname, settings }:

let
  lib = inputs.nixpkgs.lib;
  settings' = settings // { inherit hostname; };
in
lib.nixosSystem {
  system = settings'.system;
  specialArgs = { inherit inputs; settings = settings'; };
  modules = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.stylix.nixosModules.stylix
    ../users/lunear.nix
    ../hosts/${hostname}/configuration.nix
    inputs.home-manager.nixosModules.home-manager
    {
      networking.hostName = hostname;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs; settings = settings'; };
        sharedModules = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
        users.${settings'.username}.imports = [ ../hosts/${hostname}/home.nix ];
      };
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    }
  ];
}
