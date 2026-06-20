# Choice-based editor: pick one with `editor = "...";` in vars.nix.
# Enables the chosen editor and points $EDITOR at it.
{ lib, config, settings, ... }:

let
  cfg = config.lunear.editor;
in
{
  options.lunear.editor = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "vim" "vscode" ]);
    default = settings.editor or "vim";
    description = "Default editor ($EDITOR).";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "vim") {
      programs.vim.enable = true;
      home.sessionVariables.EDITOR = "vim";
    })
    (lib.mkIf (cfg == "vscode") {
      programs.vscode.enable = true;
      home.sessionVariables.EDITOR = "code --wait";
    })
  ];
}
