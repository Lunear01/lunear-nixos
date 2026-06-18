{config, pkgs, lib, ...}:

{
    home.username = "lunear";
    home.homeDirectory = "/home/lunear";
    home.stateVersion = "26.05";
    programs.bash = {
        enable = true;
        shellAliases = {
            nrs = "sudo nixos-rebuild --flake /etc/nixos#lunear-nixos switch";
            btw = "echo i use nix btw";
        };
    };
}
