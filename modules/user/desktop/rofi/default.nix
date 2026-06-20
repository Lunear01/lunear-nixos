{ pkgs, palette, themed, lib, config, ... }:

let
  cfg = config.lunear.home.rofi;
  base01 = config.lib.stylix.colors.withHashtag.base01;

  # rofi's color vocabulary, from the selected Stylix base16 theme. The glass-*
  # variants append an alpha byte (#rrggbb -> #rrggbbaa) so Hyprland's layer blur
  # frosts whatever shows through. theme.rasi/wallpaper.rasi/cliphist.rasi
  # @import this from an absolute path (theme.rasi is loaded from the store).
  colorsRasi = pkgs.writeText "colors-rofi.rasi" ''
    * {
        background:     ${palette.background};
        background-alt: ${base01};
        foreground:     ${palette.foreground};
        selected:       ${palette.color4};
        active:         ${palette.color2};
        urgent:         ${palette.color1};

        glass:          ${palette.background}b3;   /* ~70% — main window pane        */
        glass-alt:      ${base01}80;               /* ~50% — inputbar/rows           */
        glass-sheen:    ${palette.foreground}1f;   /* ~12% — hairline highlight edge */
        glass-sel:      ${palette.color4}cc;       /* ~80% — selected element        */
    }
  '';
in
{
  options.lunear.home.rofi.enable = lib.mkEnableOption "rofi launcher";

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      theme = "${themed ./dotfiles/theme.rasi}";
    };

    xdg.configFile = {
      "rofi/colors.rasi".source = colorsRasi;
      "rofi/wallpaper.rasi".source = themed ./dotfiles/wallpaper.rasi;
      "rofi/cliphist.rasi".source = themed ./dotfiles/cliphist.rasi;
    };
  };
}
