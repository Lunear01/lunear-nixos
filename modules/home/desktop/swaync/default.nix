{ themed, ... }:

{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "left";
      positionY = "top";
      control-center-positionX = "left";
      control-center-positionY = "top";
    };
  };

  xdg.configFile."swaync/style.css".source = themed ./dotfiles/style.css;
}
