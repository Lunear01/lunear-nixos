{ pkgs, ... }:

{
  programs.git.enable = true;
  programs.vscode.enable = true;

  home.packages = with pkgs; [
    claude-code
    nodejs_22
    gh
    python3
  ];
}
