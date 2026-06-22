{ pkgs, ... }:

{
  # Run unpatched binaries (npm, claude-code, etc.)
  programs.nix-ld.enable = true;

  # Shared libraries that prebuilt / pip-installed binaries dlopen at runtime.
  # e.g. numpy, lxml, psycopg wheels need libstdc++ and libz; without these
  # nix-ld resolves the loader but the libs are missing -> ImportError.
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
  ];
}
