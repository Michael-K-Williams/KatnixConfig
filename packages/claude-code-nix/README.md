# Claude Code Nix Overlay

This repository provides a Nix overlay for Claude Code, allowing you to use an updated version of Claude Code in your NixOS configuration.

## Features

- Provides the latest Claude Code version (currently 1.0.83)
- Includes update script for easy version bumping
- Packaged as a flake for easy integration

## Usage

### As a Flake Input

Add this to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    claude-code.url = "github:Michael-K-Williams/Claude-Code-Nix";
    # ... other inputs
  };

  outputs = { self, nixpkgs, claude-code, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [ claude-code.overlays.default ];
          environment.systemPackages = with pkgs; [
            claude-code
          ];
        }
        # ... other modules
      ];
    };
  };
}
```

### Direct Import

You can also import the overlay directly:

```nix
{
  nixpkgs.overlays = [ 
    (import (builtins.fetchTarball "https://github.com/Michael-K-Williams/Claude-Code-Nix/archive/main.tar.gz"))
  ];
}
```

## Updating

The overlay includes an update script. To update to the latest version, you can run the update script or manually update the version and hash in `overlay.nix`.

## License

This project is open source and available under the [MIT License](LICENSE).
