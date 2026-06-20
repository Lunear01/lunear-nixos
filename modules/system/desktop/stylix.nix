# Stylix — static base16 identity for everything Stylix can theme (GTK, Qt,
# cursor, icons, fonts, console, Firefox, VSCode, vim, ...). The scheme is
# selectable: `lunear.theme.name` (default from systemSettings.theme) is looked
# up in themes/default.nix. The five dynamic apps (kitty, waybar, rofi, swaync,
# hyprland) stay wallust-driven; their Stylix targets are turned off in
# modules/user/desktop/stylix.nix so nothing is themed twice.
#
# Wallpaper is owned by awww/wallust, so `stylix.image` is intentionally unset
# (a base16Scheme makes it optional). Edits here need a rebuild:
#   sudo nixos-rebuild switch --flake /etc/nixos#lunear-nixos
{ pkgs, lib, config, systemSettings, ... }:

let
  cfg = config.lunear.theme;
  themes = import ../../../themes { inherit pkgs; };
  theme = themes.${cfg.name};
in
{
  options.lunear.theme = {
    stylix.enable = lib.mkEnableOption "Stylix base16 theming";
    name = lib.mkOption {
      type = lib.types.enum (lib.attrNames themes);
      default = systemSettings.theme or "everforest-dark-hard";
      description = "Named base16 theme for the Stylix base layer.";
    };
  };

  config = lib.mkIf cfg.stylix.enable {
    stylix = {
      enable = true;
      inherit (theme) polarity base16Scheme;

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
