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
        mkHost = import ./lib/mkHost.nix inputs;
    in {
        nixosConfigurations.lunear-nixos = mkHost {
            hostname = "lunear-nixos";
            users = [ "lunear" ];
        };
    };
}
