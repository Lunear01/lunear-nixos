# Exposes `themed` to every home module via _module.args. It copies a repo
# dotfile into the store, substituting @home@ with the real home directory so
# nothing hardcodes a username/path.
{ config, pkgs, ... }:

{
  _module.args.themed =
    src: pkgs.replaceVars src { home = config.home.homeDirectory; };
}
