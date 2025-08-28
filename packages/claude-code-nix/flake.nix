{
  description = "Claude Code overlay for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        overlays.default = import ./overlay.nix;
        
        packages.claude-code = pkgs.extend self.overlays.default;
        
        # For backwards compatibility
        overlay = self.overlays.default;
      }
    ) // {
      # Make overlay available to other flakes
      overlays.default = import ./overlay.nix;
    };
}
