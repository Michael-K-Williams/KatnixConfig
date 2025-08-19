{ config, pkgs, inputs, ... }:
{
  # Bootloader configuration
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      theme = inputs.grub-xenlism-nixos.packages.${pkgs.system}.xenlism-grub-1080p-nixos;
    };
    efi.canTouchEfiVariables = true;
  };
}
