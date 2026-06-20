# Choice-based terminal: pick one with `terminal = "...";` in users/<u>/vars.nix.
# The selection drives the matching guarded module under modules/user/desktop/.
{ lib, config, userSettings, ... }:

let
  cfg = config.lunear.terminal;
in
{
  options.lunear.terminal = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "kitty" ]);
    default = userSettings.terminal or "kitty";
    description = "Terminal emulator.";
  };

  config = lib.mkIf (cfg == "kitty") { lunear.home.kitty.enable = true; };
}
