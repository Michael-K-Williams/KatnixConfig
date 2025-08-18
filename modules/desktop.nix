{ config, pkgs, machineConfig, ... }:
{
  # Desktop environment configuration
  services = {
    xserver = {
      enable = false; # X11 disabled in favor of Wayland
      xkb = {
        layout = "gb";
        variant = "";
      };
    };
    
    displayManager.sddm = {
      enable = true;
      theme = "breeze";
      settings = {
        Theme = {
          Background = toString machineConfig.backgroundImagePath;
        };
      };
    };
    
    desktopManager.plasma6.enable = true;
    printing.enable = true;
  };

  # Exclude unwanted KDE packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    elisa
    ark
    khelpcenter
    okular
  ];
}
