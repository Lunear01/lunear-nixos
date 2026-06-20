# Recursive .nix importer. Given a directory, returns the list of module paths
# to import: a subdirectory holding a default.nix is imported as-is; any other
# subdirectory is recursed into; bare *.nix files (except default.nix) are
# included directly. Lets module dirs be blanket-imported without a hand-kept
# list — drop a file in, it's picked up next rebuild.
#
# Usage: imports = import ../../lib/importAll.nix lib ./.;
lib:

let
  go = dir: lib.flatten (lib.mapAttrsToList (name: type:
    let p = dir + "/${name}"; in
    if type == "directory" then
      (if builtins.pathExists (p + "/default.nix") then [ p ] else go p)
    else if lib.hasSuffix ".nix" name && name != "default.nix" then [ p ]
    else [ ]
  ) (builtins.readDir dir));
in
go
