{
    description = "Lunear's NixOS";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, home-manager, ... }: {
        nixosConfigurations.lunear-nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.lunear = import ./home.nix;
                        backupFileExtension = "backup";
                    };
                    # Pin the registry so `nix run nixpkgs#foo` uses the
                    # same locked nixpkgs as the system, not a fresh download.
                    nix.registry.nixpkgs.flake = nixpkgs;
                    nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
                }
            ];
        };
    };
}
