{ pkgs, palette, lib, config, ... }:

let
  cfg = config.lunear.home.fcitx5;

  # Candidate-window font. Follows the active Stylix sans-serif; the system
  # i18n module installs Noto Sans CJK so Han glyphs resolve via fontconfig.
  fontName = config.stylix.fonts.sansSerif.name or "Noto Sans";
  font = "${fontName} 13";

  # Colors from the selected Stylix base16 palette (same source as waybar/rofi).
  bg     = palette.background;   # base00 — panel fill
  fg     = palette.foreground;   # base05 — candidate text
  accent = palette.color4;       # base0D — highlight / border

  # fcitx5 classicui has no border-radius key: rounded corners come from a
  # 9-slice PNG. The corner radius == the Margin declared in theme.conf, so
  # fcitx5 keeps the curved corners un-stretched and tiles only the flat center.
  themeConf = pkgs.writeText "theme.conf" ''
    [Metadata]
    Name=Stylix
    Version=1
    Author=lunear-nixos
    Description=Generated from the active Stylix base16 palette.
    ScaleWithDPI=True

    [InputPanel]
    NormalColor=${fg}
    HighlightCandidateColor=${bg}
    HighlightColor=${fg}
    HighlightBackgroundColor=${accent}
    PageButtonAlignment=Last Candidate

    [InputPanel/TextMargin]
    Left=8
    Right=8
    Top=4
    Bottom=4

    [InputPanel/ContentMargin]
    Left=8
    Right=8
    Top=8
    Bottom=8

    [InputPanel/Background]
    Image=background.png

    [InputPanel/Background/Margin]
    Left=12
    Right=12
    Top=12
    Bottom=12

    [InputPanel/Highlight]
    Image=highlight.png
    Color=${accent}

    [InputPanel/Highlight/Margin]
    Left=10
    Right=10
    Top=10
    Bottom=10

    [Menu/Background]
    Color=${bg}
    BorderColor=${accent}
    BorderWidth=1

    [Menu/Background/Margin]
    Left=2
    Right=2
    Top=2
    Bottom=2

    [Menu/ContentMargin]
    Left=4
    Right=4
    Top=4
    Bottom=4

    [Menu/Highlight]
    Color=${accent}

    [Menu/Highlight/Margin]
    Left=4
    Right=4
    Top=4
    Bottom=4

    [Menu/Separator]
    Color=${accent}
  '';

  # The theme dir: rounded 9-slice PNGs + theme.conf, assembled at build time.
  # background.png — 12px radius (matches the Background/Margin above).
  # highlight.png  — 10px radius pill for the selected candidate.
  themeDir = pkgs.runCommand "fcitx5-stylix-theme"
    { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    mkdir -p $out
    magick -size 26x26 xc:none -fill '${bg}' -stroke '${accent}' -strokewidth 1 \
      -draw 'roundrectangle 0,0,25,25,12,12' $out/background.png
    magick -size 22x22 xc:none -fill '${accent}' \
      -draw 'roundrectangle 0,0,21,21,10,10' $out/highlight.png
    cp ${themeConf} $out/theme.conf
  '';

  # Addon conf files (conf/*.conf) are FLAT key=value — no [section] header
  # (unlike theme.conf). A header would bury every key and fcitx5 ignores them.
  classicuiConf = pkgs.writeText "classicui.conf" ''
    Vertical Candidate List=False
    WheelForPaging=True
    Font=${font}
    MenuFont=${font}
    TrayFont=${font}
    PreferTextIcon=False
    ShowLayoutNameInIcon=True
    UseInputMethodLanguageToDisplayText=True
    Theme=stylix
    DarkTheme=stylix
    UseDarkTheme=False
    EnableFractionalScale=True
  '';
in
{
  options.lunear.home.fcitx5.enable =
    lib.mkEnableOption "Stylix-themed fcitx5 candidate window (rounded, horizontal)";

  config = lib.mkIf cfg.enable {
    xdg.dataFile."fcitx5/themes/stylix".source = themeDir;
    xdg.configFile."fcitx5/conf/classicui.conf".source = classicuiConf;
  };
}
