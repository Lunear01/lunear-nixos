{ config, lib, ... }:

let
  cfg = config.lunear.desktop.audio;
in
{
  options.lunear.desktop.audio.enable =
    lib.mkEnableOption "PipeWire audio stack";

  config = lib.mkIf cfg.enable {
    # Real-time scheduling for PipeWire
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
