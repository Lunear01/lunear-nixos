# Bash config. Reads the host name from systemSettings so the `nrs` rebuild
# alias targets the right flake attribute on any machine.
{ lib, config, systemSettings, ... }:

let
  cfg = config.lunear.home.bash;
in
{
  options.lunear.home.bash.enable = lib.mkEnableOption "Bash shell config";

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellAliases = {
        nrs = "sudo nixos-rebuild --flake /etc/nixos#${systemSettings.hostname} switch";
        btw = "echo i use nix btw";
        die = "poweroff";
      };
    };
  };
}
