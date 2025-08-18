{ config, pkgs, ... }:
{
  # Allow unfree packages - This is required for NVIDIA Drivers.
  nixpkgs.config.allowUnfree = true;

  # Use LTS kernel, as latest doesn't play nice with NVIDIA.
  boot.kernelPackages = pkgs.linuxPackages;

  services.xserver.videoDrivers = ["nvidia"];

  # NVIDIA Config
  hardware = {
    graphics = {
      enable = true;
    };
    nvidia = {
      modesetting.enable = true; 
      powerManagement.enable = false; 
      powerManagement.finegrained = false; 
      open = true; # Remember, Open = new drivers.
      nvidiaSettings = true; 
      package = config.boot.kernelPackages.nvidiaPackages.latest; 
    };
  };
}