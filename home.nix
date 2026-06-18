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
    programs.kitty = {
        enable = true;
        extraConfig = ''
            include /home/lunear/.cache/wal/colors-kitty.conf
            # Liquid glass: let the (blurred) desktop show through; allows live
            # opacity tweaks. Run fastfetch on every launch via the session file.
            dynamic_background_opacity yes
            startup_session /home/lunear/.config/kitty/session.conf
        '';
    };
    programs.rofi = {
        enable = true;
        # Layout lives in the repo; colors come from the wallpaper via wallust.
        theme = "/home/lunear/.config/rofi/theme.rasi";
    };
    programs.fastfetch.enable = true;
    programs.vscode.enable = true;

    # wallust — generates the colorscheme from the wallpaper (see wallust/).
    home.packages = [ pkgs.wallust ];

    # Services
    services.swaync.enable = true;
    services.cliphist.enable = true;
    services.playerctld.enable = true;

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
        "waybar/style.css".source = ./hyprland-config/waybar/style.css;

        # Pywal-style theming via wallust: wallpaper -> palette -> every app.
        "wallust/wallust.toml".source = ./hyprland-config/wallust/wallust.toml;
        "wallust/templates".source = ./hyprland-config/wallust/templates;
        "rofi/theme.rasi".source = ./hyprland-config/rofi/theme.rasi;
        "kitty/session.conf".source = ./hyprland-config/kitty/session.conf;
        "swaync/style.css".source = ./hyprland-config/swaync/style.css;

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
