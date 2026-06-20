# Single source of truth for this NixOS config. Threaded to every module as the
# `settings` arg: a specialArg for system modules, and per-user `_module.args`
# for home modules (each user also gets its own `username`). `hostname` is
# derived from the host directory name in lib/mkHost.nix, so it is not set here.
#
# Multi-host: this file holds the shared defaults. A host may override any field
# by dropping a partial attrset in hosts/<name>/vars.nix (merged on top).
{
  system = "x86_64-linux";
  users = [ "lunear" ];

  # Stylix base16 theme (see themes/).
  theme = "catppuccin-mocha";

  # Primary user + choice-based app modules (browser/terminal/editor enums).
  username = "lunear";
  browser = "zen";
  terminal = "kitty";
  editor = "vscode";
}
