{
  description = "VS Code Mutable Installer - NixOS package for installing VS Code in a mutable way";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        vscode-package = import ./default.nix { inherit pkgs; };
      in
      {
        packages = {
          vscode-mutable = vscode-package.vscode-mutable;
          vscode-fhs = vscode-package.vscode-fhs;
          vscode-fhs-complete = vscode-package.vscode-fhs-complete;
          vscode-complete = vscode-package.vscode-complete;
          default = vscode-package.vscode-fhs-complete;
        };

        apps = {
          vscode-mutable = {
            type = "app";
            program = "${vscode-package.vscode-mutable}/bin/vscode-mutable-installer";
          };
          vscode-fhs = {
            type = "app";
            program = "${vscode-package.vscode-fhs}/bin/code";
          };
          default = {
            type = "app";
            program = "${vscode-package.vscode-mutable}/bin/vscode-mutable-installer";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix-build-uncached
            nix-tree
            nix-index
          ];
          
          shellHook = ''
            echo "VS Code Mutable Installer development environment"
            echo ""
            echo "To build: nix build .#vscode-mutable"
            echo "To run: nix run .#vscode-mutable"
          '';
        };
      }) // {
        overlays.default = final: prev: {
          vscode-mutable = (import ./default.nix { pkgs = final; }).vscode-mutable;
          vscode-fhs = (import ./default.nix { pkgs = final; }).vscode-fhs;
          vscode-fhs-complete = (import ./default.nix { pkgs = final; }).vscode-fhs-complete;
          # Override the regular vscode package with our FHS version
          vscode = (import ./default.nix { pkgs = final; }).vscode-fhs-complete;
        };

        nixosModules.default = { config, lib, pkgs, ... }:
          let
            cfg = config.programs.vscode-mutable;
            vscode-package = import ./default.nix { inherit pkgs; };
          in
          {
            options.programs.vscode-mutable = {
              enable = lib.mkEnableOption "VS Code Mutable Installer";
              
              userName = lib.mkOption {
                type = lib.types.str;
                description = "Username for VS Code installation";
              };

              installDir = lib.mkOption {
                type = lib.types.str;
                default = "/opt/vscode-mutable";
                description = "Directory to install VS Code";
              };

              vscodeUrl = lib.mkOption {
                type = lib.types.str;
                default = "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64";
                description = "URL to download VS Code from";
              };

              fallbackUrl = lib.mkOption {
                type = lib.types.str;
                default = "https://az764295.vo.msecnd.net/stable/384ff7382de624fb94dbaf6da11977bba1ecd427/code-stable-x64-1733244016.tar.gz";
                description = "Fallback URL if primary download fails";
              };

              fonts = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = with pkgs; [
                  nerd-fonts.fira-code
                  nerd-fonts.jetbrains-mono
                  nerd-fonts.ubuntu-mono
                  nerd-fonts.dejavu-sans-mono
                  cascadia-code
                  nerd-fonts.meslo-lg
                  nerd-fonts.droid-sans-mono
                ];
                description = "Fonts to install for VS Code";
              };
            };

            config = lib.mkIf cfg.enable {
              environment.systemPackages = [ 
                vscode-package.vscode-fhs-complete
              ];
              
              # Add /usr/local/bin to system PATH
              environment.localBinInPath = true;

              # Install fonts for VS Code
              fonts.packages = cfg.fonts;

              # Install VS Code mutably during system activation  
              system.activationScripts.vscode-mutable = 
                let
                  vscode-complete = pkgs.callPackage ./vscode-complete.nix { userName = cfg.userName; };
                in vscode-complete.vscode-activation-script;

              # Ensure VS Code can run with necessary libraries
              programs.nix-ld.enable = true;
              programs.nix-ld.libraries = with pkgs; [
                # Libraries that VS Code might need
                stdenv.cc.cc
                zlib
                fuse3
                icu
                nss
                nspr
                fontconfig
                freetype
                pango
                gtk3
                gdk-pixbuf
                cairo
                glib
                atk
                at-spi2-atk
                dbus
                cups
                expat
                libdrm
                libxkbcommon
                mesa
                alsa-lib
              ];
            };
          };
      };
}
