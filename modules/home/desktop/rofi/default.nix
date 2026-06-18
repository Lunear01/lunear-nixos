{ themed, ... }:

{
  programs.rofi = {
    enable = true;
    theme = "${themed ./dotfiles/theme.rasi}";
  };

  xdg.configFile = {
    "rofi/wallpaper.rasi".source = themed ./dotfiles/wallpaper.rasi;
    "rofi/cliphist.rasi".source = themed ./dotfiles/cliphist.rasi;
  };
}
