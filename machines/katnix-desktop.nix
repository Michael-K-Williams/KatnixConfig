# Machine-specific configuration for Katnix Desktop
{
  # Machine identification
  hostName = "Katnix-Desktop";
  machineType = "Desktop";
  
  # User configuration
  userName = "thealtkitkat";
  userDescription = "Kat";
  
  # Paths
  configPath = "/home/thealtkitkat/nixos";
  backgroundImagePath = "/home/thealtkitkat/nixos/nix-dark.png";
  
  # Hardware-specific imports
  hardwareImports = [
    ../nvidia.nix
    # ../intel-graphics.nix  # Commented out for desktop
  ];
  
  # Display configuration
  displayManager = {
    enable = true;
    theme = "breeze";
  };
  
  # Desktop environment
  desktopManager = {
    plasma6.enable = true;
  };
  
  # Graphics (can be "nvidia", "intel", or "hybrid")
  graphics = "nvidia";
  
  # Elite Dangerous applications
  includeEliteDangerous = true;
}