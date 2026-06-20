{ pkgs, lib, config, ... }:

let
  cfg = config.lunear.home.dev;
in
{
  options.lunear.home.dev.enable =
    lib.mkEnableOption "developer tooling (git, vscode, language runtimes)";

  config = lib.mkIf cfg.enable {
    programs.git.enable = true;
    programs.vscode = {
      enable = true;
      profiles.default.userSettings = {
        "terminal.integrated.gpuAcceleration" = "off";
        "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font Mono";
      };
    };

    home.packages = with pkgs; [
      claude-code
      nodejs_22
      gh
      python3
    ];
  };
}
