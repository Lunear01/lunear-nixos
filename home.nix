{ config, pkgs, lib, ... }:

let
    home = config.home.homeDirectory;
    # Copy a repo dotfile into the store, substituting @home@ with the real
    # home directory so nothing hardcodes a username/path.
    themed = src: pkgs.replaceVars src { inherit home; };
in
{
    home.username = "lunear";
    home.homeDirectory = "/home/${config.home.username}";
    home.stateVersion = "26.05";

    home.sessionVariables = {
        EDITOR = "vim";
    };

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
    programs.kitty = {
        enable = true;
        extraConfig = ''
            include ${home}/.cache/wal/colors-kitty.conf
            dynamic_background_opacity yes
            startup_session ${home}/.config/kitty/session.conf
        '';
    };
    programs.rofi = {
        enable = true;
        theme = "${themed ./hyprland-config/rofi/theme.rasi}";
    };
    programs.fastfetch.enable = true;
    programs.vscode.enable = true;
    programs.firefox.enable = true;
    programs.vim.enable = true;

    fonts.fontconfig.enable = true;

    xdg.userDirs = {
        enable = true;
        createDirectories = true;
    };

    home.packages = with pkgs; [
        # Theming
        wallust

        # CLI utilities
        tree
        wget

        # Desktop / Wayland
        awww
        hyprshell
        hyprshot
        nautilus
        wl-clipboard
        libnotify
        pavucontrol
        brightnessctl
        overskride

        # Browser Web app
        chromium

        # VPN / networking
        wireguard-tools
        proton-vpn

        # Dev tools
        claude-code

        # Fonts
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
    ];

    # Flatpak
    services.flatpak.packages = [
        "app.zen_browser.zen"
    ];

    # Services
    services.swaync = {
        enable = true;
        settings = {
            positionX = "left";
            positionY = "top";
            control-center-positionX = "left";
            control-center-positionY = "top";
        };
    };
    services.cliphist.enable = true;
    services.playerctld.enable = true;

    systemd.user.services.waybar = {
        Unit.StartLimitIntervalSec = 0;
        Service = {
            Restart = "on-failure";
            RestartSec = 2;
        };
    };

    # Session target
    systemd.user.targets.hyprland-session = {
        Unit = {
            Description = "Hyprland compositor session";
            Documentation = [ "man:systemd.special(7)" ];
            BindsTo = [ "graphical-session.target" ];
            Before = [ "graphical-session.target" ];
            Wants = [ "graphical-session-pre.target" ];
            After = [ "graphical-session-pre.target" ];
        };
    };

    # Dotfiles
    xdg.configFile = {
        "hypr/hyprland.lua".source = ./hyprland-config/hypr/hyprland.lua;
        "waybar/config.jsonc".source = ./hyprland-config/waybar/config.jsonc;
        "waybar/style.css".source = themed ./hyprland-config/waybar/style.css;

        # Pywal-style theming via wallust: wallpaper -> palette -> every app.
        "wallust/wallust.toml".source = themed ./hyprland-config/wallust/wallust.toml;
        "wallust/templates".source = ./hyprland-config/wallust/templates;
        "kitty/session.conf".source = ./hyprland-config/kitty/session.conf;
        "swaync/style.css".source = themed ./hyprland-config/swaync/style.css;

        # Scripts are exec'd directly (see hypr/hyprland.lua), so keep +x.
        "hypr/scripts/theme.sh" = {
            source = ./hyprland-config/scripts/theme.sh;
            executable = true;
        };
        "hypr/scripts/wallpaper-picker.sh" = {
            source = ./hyprland-config/scripts/wallpaper-picker.sh;
            executable = true;
        };
    };
}
