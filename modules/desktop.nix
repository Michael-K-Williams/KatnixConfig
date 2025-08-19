{ config, pkgs, machineConfig, ... }:
{
  # Desktop environment configuration
  services = {
    xserver = {
      enable = true; # Required for GDM even with Wayland
      displayManager.gdm.enable = true;
      xkb = {
        layout = "gb";
        variant = "";
      };
    };
    
    displayManager = {
      defaultSession = "plasma";
      sddm = {
        theme = "where_is_my_sddm_theme";
        package = pkgs.kdePackages.sddm-kcm;
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
    kscreenlocker
  ];
}
