# Stylix — static Everforest Dark Hard identity for everything Stylix can theme
# (GTK, Qt, cursor, icons, fonts, console, Firefox, VSCode, vim, ...). The five
# dynamic apps (kitty, waybar, rofi, swaync, hyprland) stay wallust-driven; their
# Stylix targets are turned off in modules/home/desktop/stylix.nix so nothing is
# themed twice.
#
# Wallpaper is owned by awww/wallust, so `stylix.image` is intentionally unset
# (a base16Scheme makes it optional). Edits here need a rebuild:
#   sudo nixos-rebuild switch --flake /etc/nixos#lunear-nixos
{ pkgs, lib, config, ... }:

let
  cfg = config.lunear.theme.stylix;
in
{
  options.lunear.theme.stylix.enable =
    lib.mkEnableOption "Stylix Everforest Dark Hard theming";

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 18;
      };

      icons = {
        enable = true;
        package = pkgs.adwaita-icon-theme;
        dark = "Adwaita";
        light = "Adwaita";
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
