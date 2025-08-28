# Elite Dangerous Market Connector (EDMC) - NixOS Package

This repository contains the NixOS package for Elite Dangerous Market Connector (EDMC), a companion app for Elite Dangerous that uploads trade and exploration data to various online databases and provides market information.

## Quick Start

### Option 1: Run directly from GitHub
```bash
# Run EDMC directly
nix run github:yourusername/EDMC

# Install EDMC
nix profile install github:yourusername/EDMC
```

### Option 2: Clone and use locally
```bash
# Clone the repository
git clone https://github.com/yourusername/EDMC.git
cd EDMC

# Run locally
nix run .

# Install from local clone
nix profile install .
```

### Option 3: Add to your NixOS configuration

Add this to your `flake.nix` inputs:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    edmc = {
      url = "github:yourusername/EDMC";
      # Optional: pin to a specific commit for reproducibility
      # url = "github:yourusername/EDMC/abc123def456";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

Then in your NixOS configuration:
```nix
{ inputs, ... }:
{
  imports = [ inputs.edmc.nixosModules.default ];
  
  programs.edmc.enable = true;
}
```

### Manual installation

```bash
# Build package
nix build .#edmc

# Install to profile
nix profile install .#edmc
```

## Development

```bash
# Enter development shell
nix develop

# Build package
nix build .#edmc

# Test package
nix run .#edmc
```

## Package Details

### EDMarketConnector
- **Version**: 5.13.1
- **Homepage**: https://github.com/EDCD/EDMarketConnector
- **Description**: Elite Dangerous Market Connector - trading and exploration data
- **License**: GPL-2.0+

A companion app for Elite Dangerous that uploads trade and exploration data to various online databases and provides market information.

## Contributing

To update the package version:

1. Update the version and SHA256 hash in `edmc.nix`
2. Test the build: `nix build .#edmc`
3. Submit a pull request

## License

This packaging is provided under GPL-2.0+ license, same as the upstream project.