# VSCode FHS Environment Overlay
# This overlay replaces the regular vscode package with our FHS environment version
# allowing extensions to modify core files while providing all necessary libraries

final: prev: 

let
  vscode-nix = final.callPackage ./default.nix { userName = "thealtkitkat"; };
in
{
  # Provide VSCode-Nix components (vscode package is provided by vscode-mutable module)
  vscode-fhs-complete = vscode-nix.vscode-fhs-complete;
  vscode-fhs = vscode-nix.vscode-fhs;
  vscode-complete = vscode-nix.vscode-complete;
  vscode-activation = vscode-nix.vscode-activation;
}