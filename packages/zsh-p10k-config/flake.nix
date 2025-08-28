{
  description = "Katnix zsh and powerlevel10k configuration flake";

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
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "katnix-zsh-p10k-config";
          version = "1.0.0";
          
          src = ./.;
          
          installPhase = ''
            mkdir -p $out/config
            cp p10k.zsh $out/config/
            cp config.jsonc $out/config/
            cp fox.txt $out/config/
          '';
        };
      }
    ) // {
      # Home Manager module
      homeManagerModule = { pkgs, config, lib, ... }:
        let
          cfg = config.programs.katnix-zsh;
          configPackage = self.packages.${pkgs.system}.default;
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
                if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                  source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
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
        };
    };
}
