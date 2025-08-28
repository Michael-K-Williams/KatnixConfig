{ pkgs ? import <nixpkgs> {}, userName ? "thealtkitkat" }:

let
  vscode-complete = pkgs.callPackage ./vscode-complete.nix { inherit userName; };
in
{
  vscode-mutable = pkgs.callPackage ./vscode.nix {};
  vscode-fhs = pkgs.callPackage ./vscode-fhs.nix {};
  vscode-complete = vscode-complete;
  
  # Main FHS environment package (matches your backup config)
  vscode-fhs-complete = vscode-complete.vscode-fhs;
  
  # Activation script for system configuration
  vscode-activation = vscode-complete.vscode-activation-script;
}
