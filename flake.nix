{
    description = "Lunear's NixOS";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-flatpak.url = "github:gmodena/nix-flatpak";
        stylix = {
            url = "github:nix-community/stylix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs@{ self, nixpkgs, home-manager, nix-flatpak, stylix, ... }:
    let
        lib = nixpkgs.lib;
        mkHost = import ./lib/mkHost.nix inputs;
        # Discover every host: each directory under ./hosts becomes a
        # nixosConfiguration. Add a machine by dropping in hosts/<name>/.
        hosts = builtins.attrNames
            (lib.filterAttrs (_: t: t == "directory") (builtins.readDir ./hosts));
    in {
        nixosConfigurations = lib.genAttrs hosts mkHost;
    };
}
