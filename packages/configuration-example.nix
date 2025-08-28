# Example of how to integrate VSCode-Nix into your NixOS configuration
# This matches the exact functionality from ~/nixos-backup/configuration.nix

{ config, pkgs, ... }:

let
  # Import the VSCode-Nix package
  vscode-nix = pkgs.callPackage ./path/to/VSCode-Nix { userName = "thealtkitkat"; };
in
{
  environment = {
    # Add the FHS environment to systemPackages
    systemPackages = with pkgs; [
      # ... your other packages ...
      vscode-nix.vscode-fhs-complete
      # ... rest of your packages ...
    ];
  };

  # Install VS Code mutably during system activation
  system.activationScripts.vscode-mutable = vscode-nix.vscode-activation;

  # Allow unfree packages (for official VSCode)
  nixpkgs.config.allowUnfree = true;
}

# Alternative usage as an overlay:
# 
# nixpkgs.overlays = [
#   (self: super: {
#     vscode-complete = super.callPackage ./path/to/VSCode-Nix {};
#   })
# ];
# 
# Then use:
# environment.systemPackages = [ pkgs.vscode-complete.vscode-fhs-complete ];
# system.activationScripts.vscode-mutable = pkgs.vscode-complete.vscode-activation;