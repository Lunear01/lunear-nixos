{ ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild --flake /etc/nixos#lunear-nixos switch";
      btw = "echo i use nix btw";
    };
  };
}
