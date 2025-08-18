{ config, pkgs, ... }:
{
  # Intel graphics configuration for i5-1235U (12th gen Alder Lake)
  
  # Use latest kernel for best Intel graphics support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.xserver.videoDrivers = ["modesetting"];

  # Intel graphics configuration
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true; # For 32-bit applications
      extraPackages = with pkgs; [
        intel-media-driver # VAAPI driver for newer Intel GPUs (>= Broadwell)
        intel-vaapi-driver # Older VAAPI driver, fallback
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };

  # Enable hardware video acceleration
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force Intel Media Driver
  };

  # Power management for Intel graphics
  services.thermald.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
}