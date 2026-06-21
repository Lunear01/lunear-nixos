{ config, lib, ... }:

let
  cfg = config.lunear.desktop.bluetooth;
in
{
  options.lunear.desktop.bluetooth.enable =
    lib.mkEnableOption "Bluetooth (with blueman applet)";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    # Experimental = battery reporting + better codec negotiation.
    hardware.bluetooth.settings.General.Experimental = true;

    services.blueman.enable = true;

    # Default audio devices to A2DP. Without this a headset can land on the
    # "off"/HSP profile on connect -> connected but no sound.
    # HFP/HSP backend kept native so headset mic still works; we only stop the
    # automatic switch to the low-quality headset profile.
    services.pipewire.wireplumber.extraConfig."51-bluez-a2dp" = {
      "monitor.bluez.properties" = {
        "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "hfp_hf" "hsp_hs" ];
        "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" ];
        "bluez5.enable-sbc-xq" = true;
        "bluez5.hfphsp-backend" = "native";
        "bluez5.autoswitch-to-headset-profile" = false;
      };
    };
  };
}
