{ hostname, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild --flake /etc/nixos#${hostname} switch";
      btw = "echo i use nix btw";
    };
  };
}
