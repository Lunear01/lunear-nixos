{ ... }:

{
  users.users.lunear = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
