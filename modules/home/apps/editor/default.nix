# Choice-based editor: pick one with `editor = "...";` in users/<u>/vars.nix.
# Enables the chosen editor and points $EDITOR at it.
{ lib, config, userSettings, ... }:

let
  cfg = config.lunear.editor;
in
{
  options.lunear.editor = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "vim" ]);
    default = userSettings.editor or "vim";
    description = "Default terminal editor ($EDITOR).";
  };

  config = lib.mkIf (cfg == "vim") {
    programs.vim.enable = true;
    home.sessionVariables.EDITOR = "vim";
  };
}
