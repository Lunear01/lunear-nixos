# Blanket-imports every system (NixOS) module via the recursive importer. core/* always
# applies; desktop/* is option-guarded (lunear.desktop.*, default off) so
# importing the whole tree is safe even for a host that wants none of it (e.g. a
# future server). Add a module by dropping a .nix file under here — no list to
# edit.
{ lib, ... }:

{
  imports = import ../../lib/importAll.nix lib ./.;
}
