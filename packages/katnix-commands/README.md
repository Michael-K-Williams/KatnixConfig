# Katnix Commands

A command-line tool for managing Katnix NixOS configurations.

## Overview

The `katnix` command provides a simple interface for common NixOS configuration management tasks, specifically designed for use with the [KatnixConfig](https://github.com/Michael-K-Williams/KatnixConfig) system.

## Installation

### Via Nix Flake (Recommended)

Add this flake as an input to your NixOS configuration:

```nix
{
  inputs = {
    # ... other inputs
    katnix-commands.url = "github:Michael-K-Williams/katnix-commands";
  };
}
```

Then add the package to your system packages:

```nix
environment.systemPackages = with pkgs; [
  # ... other packages
  inputs.katnix-commands.packages.${system}.default
];
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/Michael-K-Williams/katnix-commands.git
cd katnix-commands

# Make executable and copy to PATH
chmod +x katnix
sudo cp katnix /usr/local/bin/
```

## Commands

### `katnix switch`
Rebuild and switch to the new NixOS configuration.
- Automatically detects your machine name based on hostname
- Runs `sudo nixos-rebuild switch --flake .#MachineName`

### `katnix update`
Update flake inputs and switch to the new configuration.
- Updates all flake inputs with `sudo nix flake update`
- Then performs a system switch
- Combines update + switch in one command

### `katnix git`
Update the configuration from the git repository.
- If `~/nixos` exists: performs `git pull origin main`
- If `~/nixos` doesn't exist: clones the KatnixConfig repository
- Automatically copies hardware configuration on first clone

### `katnix edit`
Clone/pull the config to `~/git-repos/` and open in VSCode.
- Clones or updates KatnixConfig in `~/git-repos/KatnixConfig`
- Opens the configuration in VSCode for editing
- Separate from the main config directory for safe editing

### `katnix dry`
Perform a dry run build to check the configuration.
- Runs `sudo nixos-rebuild dry-run --flake .#MachineName`
- Validates configuration without making changes
- Useful for testing before switching

### `katnix help`
Display help information and usage examples.

## Machine Name Detection

The tool automatically detects your machine configuration based on hostname:

- Hostnames ending in `-desktop` or `Desktop` → `KatnixDesktop`
- Hostnames ending in `-laptop` or `Laptop` → `KatnixLaptop`
- Other hostnames → `Katnix` + capitalized hostname

## Directory Structure

- **`~/nixos`**: Main configuration directory (used by switch, update, dry, git)
- **`~/git-repos/KatnixConfig`**: Editing directory (used by edit command)

## Requirements

- NixOS system with flakes enabled
- Git installed
- VSCode installed (for edit command)
- Sudo access for system rebuilds

## Usage Examples

```bash
# Quick system switch
katnix switch

# Update everything and switch
katnix update

# Get latest config from git
katnix git

# Edit configuration in VSCode
katnix edit

# Test configuration without switching
katnix dry

# Show help
katnix help
```

## Features

- **Colorized output** with emoji indicators
- **Automatic machine detection** based on hostname
- **Error handling** with helpful messages
- **NixOS validation** ensures commands only run on NixOS
- **Directory management** handles missing directories gracefully

## Integration with KatnixConfig

This tool is designed to work seamlessly with the [KatnixConfig](https://github.com/Michael-K-Williams/KatnixConfig) system, providing a unified interface for all common configuration management tasks.

## License

MIT License - see LICENSE file for details.
