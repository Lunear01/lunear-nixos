{config, pkgs, lib, ...}:

{
    home.username = "lunear";
    home.homeDirectory = "/home/lunear";
    home.stateVersion = "26.05";


    # Programs
    programs.bash = {
        enable = true;
        shellAliases = {
            nrs = "sudo nixos-rebuild --flake /etc/nixos#lunear-nixos switch";
            btw = "echo i use nix btw";
        };
    };
    programs.waybar = {
        enable = true;
        systemd.enable = true;
    };
    programs.git.enable = true;
    programs.kitty.enable = true;
    programs.rofi.enable = true;
    programs.fastfetch.enable = true;
    programs.vscode.enable = true;

    # Services
    services.swaync.enable = true;
    services.cliphist.enable = true;
    services.playerctld.enable = true;

    # Dotfiles — symlinked live to the repo so edits apply without a rebuild.
    # Requires the flake to be cloned at /etc/nixos (the standard location).
    xdg.configFile."hypr/hyprland.lua".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/hypr/hyprland.lua";
}
