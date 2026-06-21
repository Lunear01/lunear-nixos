{ config, lib, pkgs, ... }:

let
  cfg = config.lunear.desktop.inputMethod;
in
{
  options.lunear.desktop.inputMethod.enable =
    lib.mkEnableOption "fcitx5 input method with the Rime engine (Chinese)";

  config = lib.mkIf cfg.enable {
    # CJK glyphs for the candidate window (Noto Sans alone has no Han coverage).
    fonts.packages = [ pkgs.noto-fonts-cjk-sans ];

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        # Wayland text-input-v3 frontend (Hyprland supports it); the gtk/qt
        # addons cover XWayland and toolkit apps that ignore the protocol.
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-rime
          fcitx5-gtk
          qt6Packages.fcitx5-configtool
        ];
      };
    };
  };
}
