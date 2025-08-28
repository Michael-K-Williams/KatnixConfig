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
    ./modules/katnix-control.nix
    ./modules/auto-update.nix
  ] ++ machineConfig.hardwareImports;

  # Pass machineConfig to modules that need it
  _module.args = { inherit machineConfig; };

  # Apply overlays
  nixpkgs.overlays = [
    # Claude-code is now provided via the main overlay in flake.nix
  ];

  # Enable Flatpak
  services.flatpak.enable = true;

  # VSCode Mutable Installation
  programs.vscode-mutable = {
    enable = true;
    userName = machineConfig.userName;
  };

  # GX52 Logitech X52 H.O.T.A.S. Control
  programs.gx52 = {
    enable = true;
    addUdevRules = true;  # Allows non-root USB device access
  };

  system.stateVersion = "25.05";
}
