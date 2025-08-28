# Katnix Zsh + Powerlevel10k Configuration Flake

This flake provides a modular zsh configuration with powerlevel10k theme, optimized for the Katnix environment.

## Features

- 🚀 Powerlevel10k theme with custom configuration
- 🛠️ Oh My Zsh integration with useful plugins
- 🔧 Custom Katnix system management aliases
- 🎨 Fastfetch integration with custom ASCII art
- ⚡ Alacritty terminal configuration
- 📦 Additional zsh plugins (zsh-lsd, zsh-bat)

## Usage

### In your NixOS flake

Add this flake as an input:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zsh-p10k-config.url = "github:yourusername/ZshP10k-Nix";
    # ... other inputs
  };

  outputs = { self, nixpkgs, zsh-p10k-config, ... }: {
    # Your configuration
  };
}
```

### In your home.nix

```nix
{ pkgs, inputs, machineConfig, ... }:

{
  imports = [ 
    inputs.zsh-p10k-config.homeManagerModule
    # ... other imports
  ];

  programs.katnix-zsh = {
    enable = true;
    machineConfig = machineConfig;
    # Optional: add extra init content
    extraInitContent = ''
      # Your custom zsh configuration here
    '';
  };
}
```

## Configuration Files

- `p10k.zsh` - Powerlevel10k theme configuration
- `config.jsonc` - Fastfetch configuration
- `fox.txt` - Custom ASCII art for terminal greeting
- `flake.nix` - Nix flake configuration

## Machine Configuration

The module expects a `machineConfig` attribute set with the following structure:

```nix
machineConfig = {
  userName = "your-username";
  configPath = "/path/to/your/nixos/config";
  hostName = "your-hostname";
  machineType = "desktop"; # or "laptop"
};
```

## Aliases

The configuration provides these convenient aliases:

- `katnix-switch` - Rebuild and switch system configuration
- `katnix-dry` - Dry build to preview changes
- `katnix-edit` - Open configuration in VS Code
- `katnix-update` - Update flake inputs and rebuild

## Customization

You can customize the configuration by:

1. Forking this repository
2. Modifying the configuration files
3. Pointing your flake input to your fork

## License

MIT License - feel free to use and modify as needed.
