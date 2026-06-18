{ pkgs, themed, ... }:

{
  services.cliphist.enable = true;
  services.playerctld.enable = true;

  home.packages = with pkgs; [
    # Theming
    wallust

    # Desktop / Wayland
    awww
    hyprshell
    hyprshot
    nautilus
    wl-clipboard
    imagemagick
    libnotify
    pavucontrol
    brightnessctl
    overskride
  ];

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
    "hypr/hyprland.lua".source = ./dotfiles/hypr/hyprland.lua;

    # Pywal-style theming via wallust: wallpaper -> palette -> every app.
    "wallust/wallust.toml".source = themed ./dotfiles/wallust/wallust.toml;
    "wallust/templates".source = ./dotfiles/wallust/templates;

    # Scripts are exec'd directly (see hypr/hyprland.lua), so keep +x.
    "hypr/scripts/theme.sh" = {
      source = ./dotfiles/scripts/theme.sh;
      executable = true;
    };
    "hypr/scripts/wallpaper-picker.sh" = {
      source = ./dotfiles/scripts/wallpaper-picker.sh;
      executable = true;
    };
    "hypr/scripts/cliphist-rofi.sh" = {
      source = ./dotfiles/scripts/cliphist-rofi.sh;
      executable = true;
    };
  };
}
