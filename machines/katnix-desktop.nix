# Machine-specific configuration for Katnix Desktop
{
  # Machine identification
  hostName = "Katnix-Desktop";
  machineType = "Desktop";
  
  # User configuration (will be overridden by installer)
  userName = "thealtkitkat";  # Default username - installer will update this
  userDescription = "Kat";
  
  # Paths (relative to configuration directory)
  backgroundImagePath = ./kat.png;
  
  # Hardware-specific imports
  hardwareImports = [
    ./nvidia.nix
    # ./intel-graphics.nix  # Commented out for desktop
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