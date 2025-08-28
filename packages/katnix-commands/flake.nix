{
  description = "Katnix command-line tool for NixOS configuration management";

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
        packages = {
          default = self.packages.${system}.katnix;
          
          katnix = pkgs.stdenv.mkDerivation rec {
            pname = "katnix";
            version = "1.0.0";
            
            src = ./.;
            
            buildInputs = with pkgs; [ bash ];
            
            installPhase = ''
              mkdir -p $out/bin
              cp katnix $out/bin/
              chmod +x $out/bin/katnix
            '';
            
            meta = with pkgs.lib; {
              description = "Command-line tool for managing Katnix NixOS configurations";
              homepage = "https://github.com/Michael-K-Williams/katnix-commands";
              license = licenses.mit;
              maintainers = [ "Michael-K-Williams" ];
              platforms = platforms.linux;
            };
          };
        };

        apps = {
          default = self.apps.${system}.katnix;
          
          katnix = {
            type = "app";
            program = "${self.packages.${system}.katnix}/bin/katnix";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bash
            shellcheck
          ];
        };
      });
}
