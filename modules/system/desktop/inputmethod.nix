{ pkgs, ... }:

{
  # CJK glyphs for the candidate window (Noto Sans alone has no Han coverage).
  fonts.packages = [ pkgs.noto-fonts-cjk-sans ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime
        fcitx5-gtk
        qt6Packages.fcitx5-configtool
      ];
    };
  };
}
