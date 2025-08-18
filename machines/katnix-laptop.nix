# Machine-specific configuration for Katnix Laptop
{
  # Machine identification
  hostName = "Katnix-Laptop";
  machineType = "Laptop";
  
  # User configuration
  userName = "thealtkitkat";
  userDescription = "Kat";
  
  # Paths (relative to configuration directory)
  backgroundImagePath = ./kat.png;
  
  # Hardware-specific imports
  hardwareImports = [
    ./intel-graphics.nix
    # ./nvidia.nix  # Commented out for laptop
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
  graphics = "intel";
  
  # Elite Dangerous applications (disabled for laptop for better battery life)
  includeEliteDangerous = false;
}