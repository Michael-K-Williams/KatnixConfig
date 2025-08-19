{
  hostName = "Katnix-Desktop";
  userName = "thealtkitkat";
  userDescription = "Katnix User";
  backgroundImagePath = ../nix-dark.png;
  
  # Hardware imports based on graphics type
  hardwareImports = [
    ../nvidia.nix
  ];
  
  # Machine type configuration
  machineType = "desktop";
  includeEliteDangerous = true;
}
