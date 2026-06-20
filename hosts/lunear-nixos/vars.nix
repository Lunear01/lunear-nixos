# Per-host settings: the single source of truth for this machine. Read by
# lib/mkHost.nix (for system/users) and threaded to every module as the
# `systemSettings` specialArg.
{
  hostname = "lunear-nixos";
  system = "x86_64-linux";
  users = [ "lunear" ];
  theme = "everforest-dark-hard";
}
