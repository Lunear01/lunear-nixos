# Blanket-imports every user (home-manager) module via the recursive importer.
# lib.nix (the `themed` helper) always applies; everything else is option-guarded
# (lunear.home.*, default off) or choice-driven (lunear.browser/terminal/editor),
# so importing the whole tree is safe — profiles flip on what a user wants. Add a
# user module by dropping a .nix file under here — no list to edit.
{ lib, ... }:

{
  imports = import ../../lib/importAll.nix lib ./.;
}
