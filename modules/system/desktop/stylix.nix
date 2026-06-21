# Stylix — static base16 identity for everything Stylix can theme (GTK, Qt,
# cursor, icons, fonts, console, Firefox, VSCode, vim, ...). The theme is
# looked up in the themes/ registry via settings.theme, where each theme is
# a self-contained directory owning its palette + config. The selected
# theme's attrs are merged into `stylix`, so a theme can override the
# cursor/icons/fonts defaults below (they are mkDefault) by declaring its
# own. kitty is themed by Stylix's native target; waybar/rofi/swaync/hyprland
# keep custom dotfiles re-sourced from this same base16 palette (see
# modules/user/desktop/stylix.nix and each module).
#
# Wallpaper is owned by awww (set at runtime via the picker), so `stylix.image`
# is intentionally unset (a base16Scheme makes it optional). Edits here need a
# rebuild:
#   sudo nixos-rebuild switch --flake /etc/nixos#<hostname>   (e.g. rog-g14)
{ pkgs, lib, settings, ... }:

let
  themes = import ../../../themes { inherit pkgs; };
  theme = themes.${settings.theme};
in
{
  config = {
    stylix = lib.mkMerge [
      # Shared defaults — mkDefault so a theme may override any of them.
      {
        enable = true;

        cursor = lib.mkDefault {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 18;
        };

        icons = lib.mkDefault {
          enable = true;
          package = pkgs.adwaita-icon-theme;
          dark = "Adwaita";
          light = "Adwaita";
        };

        fonts = lib.mkDefault {
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
      }

      # Selected theme: supplies polarity + base16Scheme, and may override the
      # defaults above with its own cursor/icons/fonts.
      theme
    ];
  };
}
