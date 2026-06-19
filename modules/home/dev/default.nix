{ pkgs, ... }:

{
  programs.git.enable = true;
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font Mono";
    };
  };

  home.packages = with pkgs; [
    claude-code
    nodejs_22
    gh
    python3
  ];
}
