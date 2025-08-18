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
    edhm = {
      url = "github:Brighter-Applications/EDHM-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    edmc = {
      url = "github:Brighter-Applications/EDMC-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-mutable = {
      url = "github:Michael-K-Williams/VSCode-mutable/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zsh-p10k-config = {
      url = "github:Michael-K-Williams/My-ZshP10k-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:Michael-K-Williams/Claude-Code-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    katnix-commands = {
      url = "github:Michael-K-Williams/Katnix-Commands";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, nix-flatpak, edhm, edmc, vscode-mutable, zsh-p10k-config, claude-code, katnix-commands, ... }@inputs: 
  let
    machineConfig = import ./machines/machine.nix;
    mkSystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs machineConfig; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        edhm.nixosModules.default
        edmc.nixosModules.default
        vscode-mutable.nixosModules.default
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
    };
  };
}
