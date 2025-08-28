{
  description = "Elite Dangerous Market Connector (EDMC) - NixOS package for Elite Dangerous trading data";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        edmc-package = import ./default.nix { inherit pkgs; };
      in
      {
        packages = {
          edmc = edmc-package.edmc;
          default = edmc-package.edmc;
        };

        apps = {
          edmc = {
            type = "app";
            program = "${edmc-package.edmc}/bin/edmarketconnector";
          };
          default = {
            type = "app";
            program = "${edmc-package.edmc}/bin/edmarketconnector";
          };
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix-build-uncached
            nix-tree
            nix-index
          ];
          
          shellHook = ''
            echo "Elite Dangerous Market Connector (EDMC) development environment"
            echo ""
            echo "To build: nix build .#edmc"
            echo "To run: nix run .#edmc"
          '';
        };
      }) // {
        overlays.default = final: prev: {
          edmc = (import ./default.nix { pkgs = final; }).edmc;
        };
        nixosModules.default = { config, lib, pkgs, ... }:
          let
            cfg = config.programs.edmc;
            edmc-package = import ./default.nix { inherit pkgs; };
          in
          {
            options.programs.edmc = {
              enable = lib.mkEnableOption "Elite Dangerous Market Connector";
            };

            config = lib.mkIf cfg.enable {
              environment.systemPackages = [ edmc-package.edmc ];
            };
          };
      };
}