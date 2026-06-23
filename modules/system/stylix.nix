# Stylix — base16 identity for everything Stylix themes (GTK, Qt, cursor,
# icons, fonts, console, Firefox, VSCode, ...). settings.theme picks a theme
# from the themes/ registry; its attrs merge over the mkDefault defaults
# below, so a theme can override cursor/icons/fonts. kitty uses Stylix's
# native target; waybar/rofi/swaync/hyprland re-source the same palette via
# their own dotfiles. Wallpaper is owned by awww at runtime, so stylix.image
# is intentionally unset (base16Scheme makes it optional).
{ pkgs, lib, settings, ... }:

let
  themes = import ../../themes { inherit pkgs; };
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
