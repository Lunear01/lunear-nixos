{ ... }:

{
  networking.hostName = "lunear-nixos";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
     # ProtonVPN requirement
    checkReversePath = false;
  };
}
