{ config, pkgs, ... }:
{
  # Nix configuration
  nix.settings = {
    download-buffer-size = 1073741824; # 1 GB
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
