{ pkgs, inputs, machineConfig ? (import ./machines/katnix-desktop.nix), ... }:

{
  imports = [ 
    inputs.plasma-manager.homeManagerModules.plasma-manager
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.zsh-p10k-config.homeManagerModule
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = machineConfig.userName;
  home.homeDirectory = "/home/${machineConfig.userName}";
  home.stateVersion = "25.05";

  # Enable Katnix zsh configuration
  programs.katnix-zsh = {
    enable = true;
    machineConfig = machineConfig;
  };

  programs.plasma = {
    enable = true;
  };

  # Flatpak configuration
  services.flatpak = {
    enable = true;
    packages = [ ];
  };

}
