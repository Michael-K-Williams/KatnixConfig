{
  description = "KooL's NixOS-Hyprland Multi-Machine Configuration"; 
  	
  inputs = {
	#nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  	nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	
	#hyprland.url = "github:hyprwm/Hyprland"; # hyprland development
	#distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";

    quickshell = {
        url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };

  	};

  outputs = 
	inputs@{ self, nixpkgs,... }:
    	let
      system = "x86_64-linux";
      username = "alternativekitkat";

    pkgs = import nixpkgs {
       	inherit system;
       	config = {
       	allowUnfree = true;
       	};
      };

    # Helper function to create a machine configuration
    mkMachine = host: nixpkgs.lib.nixosSystem rec {
      specialArgs = { 
        inherit system;
        inherit inputs;
        inherit username;
        inherit host;
      };
      modules = [ 
        ./hosts/${host}/config.nix 
        # inputs.distro-grub-themes.nixosModules.${system}.default
        ./modules/quickshell.nix  # quickshell module
      ];
    };

    in
      {
	nixosConfigurations = {
      # Legacy configuration (keeping for compatibility)
      "default" = mkMachine "default";
      "NixOS-Hyprland" = mkMachine "default";  # For backward compatibility
      
      # New machine configurations
      "Katnix-Laptop" = mkMachine "Katnix-Laptop";
      "Katnix-Desktop" = mkMachine "Katnix-Desktop";
	};
};
}