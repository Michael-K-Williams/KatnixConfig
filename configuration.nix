{ config, pkgs, inputs ? {}, machineConfig ? (import ./machines/katnix-desktop.nix), ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/nix.nix
    ./modules/networking.nix
    ./modules/audio.nix
    ./modules/desktop.nix
    ./modules/packages.nix
    ./modules/users.nix
    ./modules/elite-dangerous.nix
    ./modules/auto-updater.nix
    ./modules/katnix-control.nix
  ] ++ machineConfig.hardwareImports;

  # Pass machineConfig to modules that need it
  _module.args = { inherit machineConfig; };

  # Apply overlays
  nixpkgs.overlays = [
    (inputs.claude-code.overlays.default or (_: _: {}))
  ];

  # Enable Flatpak
  services.flatpak.enable = true;

  # VSCode Mutable Installation
  programs.vscode-mutable = {
    enable = true;
    userName = machineConfig.userName;
  };

  system.stateVersion = "25.05";
}
