# Theme registry. Each subdir is a self-contained theme owning its palette and
# Stylix config (default.nix). Auto-discovered: every dir name becomes a
# selectable theme, so adding one is just dropping a themes/<name>/ folder.
# Selected via `theme = "<name>";` in vars.nix; resolved in modules/system/stylix.nix.
{ pkgs }:

# Pure builtins only: this is imported from stylix.nix while options are built,
# so forcing `pkgs`/`lib` here to compute names would cause infinite recursion.
# Names come from readDir; `pkgs` is captured lazily per theme, forced only when
# that theme is selected.
let
  entries = builtins.readDir ./.;
  names = builtins.filter (n: entries.${n} == "directory") (builtins.attrNames entries);
in
builtins.listToAttrs (map (name: {
  inherit name;
  value = import (./. + "/${name}") { inherit pkgs; };
}) names)
