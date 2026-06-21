# fastfetch — system info banner with a custom THEORY ascii logo + gold theme.
# Config is shipped verbatim (config.jsonc) rather than via programs.fastfetch
# `settings`, because the logo/headers carry raw ANSI escapes () that Nix
# string literals cannot represent. fastfetch reads ~/.config/fastfetch/config.jsonc.
{ ... }:

{
  programs.fastfetch.enable = true;
  xdg.configFile."fastfetch/config.jsonc".source = ./config.jsonc;
}
