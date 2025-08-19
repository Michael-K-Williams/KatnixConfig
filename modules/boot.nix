{ config, pkgs, ... }:
{
  # Bootloader configuration
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      theme = pkgs.nixos-grub2-theme;
    };
    efi.canTouchEfiVariables = true;
  };
}
