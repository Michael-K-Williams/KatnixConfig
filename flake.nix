{
  description = "NixOS configuration with home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
    # EDHM still needs to be from GitHub as we don't have it locally
    edhm = {
      url = "github:Brighter-Applications/EDHM-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, nix-flatpak, edhm, ... }@inputs: 
  let
    machineConfig = import ./machines/machine.nix;
    
    # Local package imports
    localPackages = {
      vscode-mutable = import ./packages/default.nix;
      claude-code = import ./packages/claude-code-nix/overlay.nix;
      katnix-commands = import ./packages/katnix-commands/flake.nix;
      gx52 = import ./packages/gx52/flake.nix;
      edmc = import ./packages/edmc-nix/default.nix;
      zsh-p10k-config = import ./packages/zsh-p10k-config/flake.nix;
    };
    
    # Apply claude-code overlay first
    claude-code-overlay = localPackages.claude-code;
    
    overlay = final: prev: (claude-code-overlay final prev) // {
      install-proton-ge-10-12 = final.callPackage ./pkgs/proton-ge-10-12.nix {};
      
      # Local package overlays
      vscode-mutable = (localPackages.vscode-mutable { pkgs = final; }).vscode-mutable;
      vscode-fhs-complete = (localPackages.vscode-mutable { pkgs = final; }).vscode-fhs-complete;
      
      # Katnix commands
      katnix = final.stdenv.mkDerivation rec {
        pname = "katnix";
        version = "1.0.0";
        src = ./packages/katnix-commands;
        buildInputs = with final; [ bash ];
        installPhase = ''
          mkdir -p $out/bin
          cp katnix $out/bin/
          chmod +x $out/bin/katnix
        '';
      };
      
      # GX52 - inline the package definition
      gx52 = let
        pythonPackages = final.python3Packages;
        injector = pythonPackages.buildPythonPackage rec {
          pname = "injector";
          version = "0.21.0";
          pyproject = true;
          src = final.fetchPypi {
            inherit pname version;
            sha256 = "sha256-kZ62uflvQL+Y/aNMeXYrIXvRVE2a3DWAX/KUjpI1bJw=";
          };
          build-system = [ pythonPackages.setuptools ];
          doCheck = false;
        };
      in final.python3Packages.buildPythonApplication rec {
        pname = "gx52";
        version = "0.7.6";
        src = final.fetchFromGitHub {
          owner = "leinardi";
          repo = "gx52";
          rev = "55100e49d987dd041885ab28f92d9bc83f63aff5";
          fetchSubmodules = true;
          sha256 = "sha256-PfR/Xu2QX3Zgo2JL3/dfGdve1V3nmEZg6sM4iIHR8r4=";
        };
        format = "other";
        postPatch = ''
          sed -i "s/meson.add_install_script('scripts\/meson_post_install.py')/# meson.add_install_script('scripts\/meson_post_install.py')/" meson.build
        '';
        nativeBuildInputs = with final; [
          meson ninja pkg-config libxml2 glib wrapGAppsHook gobject-introspection
        ];
        buildInputs = with final; [
          gtk3 libusb1 udev libappindicator-gtk3 gsettings-desktop-schemas libnotify
        ];
        propagatedBuildInputs = with pythonPackages; [
          evdev injector peewee pygobject3 pyudev pyusb pyxdg requests reactivex setuptools
        ];
        configurePhase = ''
          runHook preConfigure
          meson setup build --prefix=$out
          runHook postConfigure
        '';
        buildPhase = ''
          runHook preBuild
          ninja -C build
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          ninja -C build install
          runHook postInstall
        '';
        postInstall = ''
          mkdir -p $out/share/applications
          mkdir -p $out/lib/udev/rules.d
          cat > $out/lib/udev/rules.d/60-gx52.rules << EOF
SUBSYSTEMS=="usb", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="0762", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="0255", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="075c", MODE="0666"
EOF
        '';
        preFixup = ''
          makeWrapperArgs+=("--prefix" "XDG_DATA_DIRS" ":" "$out/share:$GSETTINGS_SCHEMAS_PATH")
        '';
      };
      
      # EDMC - inline the package definition
      edmc = (localPackages.edmc { pkgs = final; }).edmc;
      
      # ZSH P10K Config
      katnix-zsh-p10k-config = final.stdenv.mkDerivation {
        pname = "katnix-zsh-p10k-config";
        version = "1.0.0";
        src = ./packages/zsh-p10k-config;
        installPhase = ''
          mkdir -p $out/config
          cp p10k.zsh $out/config/
          cp config.jsonc $out/config/
          cp fox.txt $out/config/
        '';
      };
    };
    
    mkSystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs machineConfig; };
      modules = [
        { nixpkgs.overlays = [ overlay ]; }
        ./configuration.nix
        home-manager.nixosModules.home-manager
        edhm.nixosModules.default
        
        # Local VSCode module
        ({ config, lib, pkgs, ... }:
          let
            cfg = config.programs.vscode-mutable;
            vscode-package = localPackages.vscode-mutable { inherit pkgs; };
          in
          {
            options.programs.vscode-mutable = {
              enable = lib.mkEnableOption "VS Code Mutable Installer";
              userName = lib.mkOption {
                type = lib.types.str;
                description = "Username for VS Code installation";
              };
            };
            config = lib.mkIf cfg.enable {
              environment.systemPackages = [ vscode-package.vscode-fhs-complete ];
              programs.nix-ld.enable = true;
              programs.nix-ld.libraries = with pkgs; [
                stdenv.cc.cc zlib fuse3 icu nss nspr fontconfig freetype pango
                gtk3 gdk-pixbuf cairo glib atk at-spi2-atk dbus cups expat
                libdrm libxkbcommon mesa alsa-lib
              ];
            };
          })
        
        # Local GX52 module
        ({ config, lib, pkgs, ... }:
          let
            cfg = config.programs.gx52;
          in
          {
            options.programs.gx52 = {
              enable = lib.mkEnableOption "GX52 Logitech X52 H.O.T.A.S. control application";
              addUdevRules = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Whether to add udev rules for X52 device access.";
              };
            };
            config = lib.mkIf cfg.enable {
              environment.systemPackages = [ pkgs.gx52 ];
              services.udev.packages = lib.mkIf cfg.addUdevRules [ pkgs.gx52 ];
              users.groups.plugdev = {};
            };
          })
        
        # Local EDMC module
        ({ config, lib, pkgs, ... }:
          let
            cfg = config.programs.edmc;
          in
          {
            options.programs.edmc = {
              enable = lib.mkEnableOption "Elite Dangerous Market Connector (EDMC)";
            };
            config = lib.mkIf cfg.enable {
              environment.systemPackages = [ pkgs.edmc ];
            };
          })
        
        # Local ZSH P10K Config module (Home Manager)
        {
          home-manager.sharedModules = [
            ({ pkgs, config, lib, ... }:
              let
                cfg = config.programs.katnix-zsh;
                configPackage = pkgs.katnix-zsh-p10k-config;
              in
              {
                options.programs.katnix-zsh = {
                  enable = lib.mkEnableOption "Katnix zsh configuration with powerlevel10k";
                  
                  machineConfig = lib.mkOption {
                    type = lib.types.attrs;
                    description = "Machine configuration containing userName, configPath, hostName, and machineType";
                  };

                  extraInitContent = lib.mkOption {
                    type = lib.types.lines;
                    default = "";
                    description = "Extra content to add to zsh init";
                  };
                };

                config = lib.mkIf cfg.enable {
                  programs.zsh = {
                    enable = true;
                    oh-my-zsh = {
                      enable = true;
                      plugins = [ "git" "sudo" "kubectl" ];
                    };
                    plugins = [
                      {
                        name = "powerlevel10k";
                        src = pkgs.zsh-powerlevel10k;
                        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                      }
                      {
                        name = "zsh-lsd";
                        src = pkgs.fetchFromGitHub {
                          owner = "z-shell";
                          repo = "zsh-lsd";
                          rev = "v1.0.0";
                          sha256 = "sha256-Hq8fejHrQ8mtKfJ5WYc8QhXLvuBYGJWztGtsXyPGzG8=";
                        };
                        file = "zsh-lsd.plugin.zsh";
                      }
                      {
                        name = "zsh-bat";
                        src = pkgs.fetchFromGitHub {
                          owner = "fdellwing";
                          repo = "zsh-bat";
                          rev = "master";
                          sha256 = "sha256-TTuYZpev0xJPLgbhK5gWUeGut0h7Gi3b+e00SzFvSGo=";
                        };
                        file = "zsh-bat.plugin.zsh";
                      }
                    ];
                    shellAliases = {
                      # Note: Katnix commands are now provided by the katnix-commands package
                      # Use 'katnix help' to see available commands
                    };
                    sessionVariables = {
                      PATH = "/usr/local/bin:$PATH";
                    };
                    initContent = ''
                      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
                      if [[ -r "\$\{XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\$\{(%):-%n}.zsh" ]]; then
                        source "\$\{XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\$\{(%):-%n}.zsh"
                      fi
                      
                      # Add space from top of terminal and show fastfetch
                      echo ""
                      echo ""
                      fastfetch
                      
                      # Show katnix commands
                      echo ""
                      echo -e "       \033[36m┌─ Katnix Commands ─────────────────────────────────────────────────┐\033[0m"
                      echo -e "       \033[36m│\033[0m \033[32mkatnix switch\033[0m   - Rebuild and switch system configuration         \033[36m│\033[0m"
                      echo -e "       \033[36m│\033[0m \033[33mkatnix dry\033[0m      - Dry build (preview changes)                     \033[36m│\033[0m"
                      echo -e "       \033[36m│\033[0m \033[35mkatnix edit\033[0m     - Clone config to ~/git-repos/ and open in VSCode \033[36m│\033[0m"
                      echo -e "       \033[36m│\033[0m \033[34mkatnix update\033[0m   - Update flake inputs and rebuild                 \033[36m│\033[0m"
                      echo -e "       \033[36m│\033[0m \033[36mkatnix git\033[0m      - Update configuration from git repository        \033[36m│\033[0m"
                      echo -e "       \033[36m│\033[0m \033[37mkatnix help\033[0m     - Show detailed help and usage examples           \033[36m│\033[0m"
                      echo -e "       \033[36m└───────────────────────────────────────────────────────────────────┘\033[0m"
                      
                      # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
                      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
                      
                      ${cfg.extraInitContent}
                    '';
                  };

                  # P10k configuration file
                  home.file.".p10k.zsh".source = "${configPackage}/config/p10k.zsh";

                  # Fastfetch configuration
                  home.file.".config/fastfetch/config.jsonc".source = "${configPackage}/config/config.jsonc";
                  home.file.".config/fastfetch/fox.txt".source = "${configPackage}/config/fox.txt";

                  # Alacritty configuration
                  programs.alacritty = {
                    enable = true;
                    settings = {
                      terminal = {
                        shell = {
                          program = "${pkgs.zsh}/bin/zsh";
                          args = [ "-l" ];
                        };
                      };
                      window = {
                        padding = {
                          x = 8;
                          y = 8;
                        };
                        title = "Katnix Terminal (${cfg.machineConfig.machineType})";
                        dynamic_title = false;
                      };
                      font = {
                        normal = {
                          family = "MesloLGS Nerd Font";
                          style = "Regular";
                        };
                        bold = {
                          family = "MesloLGS Nerd Font";
                          style = "Bold";
                        };
                        italic = {
                          family = "MesloLGS Nerd Font";
                          style = "Italic";
                        };
                        size = 12;
                      };
                    };
                  };
                };
              })
          ];
        }
        
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs machineConfig; };
          home-manager.users.${machineConfig.userName} = import ./home.nix;
        }
      ];
    };
  in {
    nixosConfigurations = {
      default = mkSystem;
      "Katnix-Desktop" = mkSystem;
    };
  };
}
