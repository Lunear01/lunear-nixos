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

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      mkHost = import ./lib/mkHost.nix { inherit inputs; };
      shared = import ./vars.nix;
    in {
      nixosConfigurations = {
        rog-g14 = mkHost {
          hostname = "rog-g14";
          settings = shared // import ./hosts/rog-g14/vars.nix;
        };
        thinkpad-t14 = mkHost {
          hostname = "thinkpad-t14";
          settings = shared // import ./hosts/thinkpad-t14/vars.nix;
        };
      };
    };
}
