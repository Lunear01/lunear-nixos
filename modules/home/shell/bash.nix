# Bash config. Reads the host name from systemSettings so the `nrs` rebuild
# alias targets the right flake attribute on any machine.
{ systemSettings, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild --flake /etc/nixos#${systemSettings.hostname} switch";
      btw = "echo i use nix btw";
      die = "poweroff";
    };
  };
}
