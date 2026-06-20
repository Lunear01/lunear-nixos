{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {

    # Flakes only
    channel.enable = false;

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-generations +5";
    };

    # Periodic store deduplication
    optimise.automatic = true;

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      # Wheel users can use nix without sudo
      trusted-users = [ "root" "@wheel" ];
    };
  };
}
