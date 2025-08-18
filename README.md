# KatnixConfig

A modular NixOS configuration system with interactive installer support.

## Overview

KatnixConfig provides a clean, modular NixOS configuration that can be easily deployed on new machines using the interactive installer. The configuration is designed to be maintainable, customizable, and machine-specific.

## Quick Installation

For new machines, use the [Katnix Installer](https://github.com/Michael-K-Williams/Katnix-Installer):

```bash
curl -O https://raw.githubusercontent.com/Michael-K-Williams/Katnix-Installer/main/install.sh
chmod +x install.sh
./install.sh
```

This will:
- Clone this repository to `~/nixos`
- Configure your machine with hostname, graphics, and features
- Install the complete Katnix system

## Manual Installation

If you prefer manual setup:

1. Clone this repository:
   ```bash
   git clone https://github.com/Michael-K-Williams/KatnixConfig.git ~/nixos
   cd ~/nixos
   ```

2. Copy your hardware configuration:
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix .
   sudo chown $USER:users hardware-configuration.nix
   ```

3. Create/modify a machine configuration in `machines/`
4. Update `flake.nix` to include your machine
5. Rebuild:
   ```bash
   sudo nixos-rebuild switch --flake .#YourMachine
   ```

## Configuration Structure

```
├── flake.nix                    # Main flake configuration with inputs
├── configuration.nix            # Core system configuration (imports modules)
├── hardware-configuration.nix   # Hardware-specific configuration
├── home.nix                     # Home Manager configuration
├── machines/
│   ├── katnix-desktop.nix      # Desktop machine configuration
│   └── katnix-laptop.nix       # Laptop machine configuration
├── modules/
│   ├── boot.nix                # Bootloader configuration
│   ├── nix.nix                 # Nix settings and overlays
│   ├── networking.nix          # Network and hostname
│   ├── audio.nix               # PipeWire audio setup
│   ├── desktop.nix             # Plasma 6 desktop environment
│   ├── packages.nix            # System packages and fonts
│   ├── users.nix               # User accounts and localization
│   └── elite-dangerous.nix     # Elite Dangerous tools (conditional)
├── intel-graphics.nix          # Intel graphics configuration
├── nvidia.nix                  # NVIDIA graphics configuration
└── kat.png                     # Desktop background
```

## Features

### Modular Design
- **Clean separation**: Each aspect of the system in its own module
- **Easy maintenance**: Find and modify specific configurations quickly
- **Reusable components**: Modules can be easily adapted for different machines

### Machine-Specific Configuration
- **Desktop**: Full-featured with gaming applications (EDHM, EDMC)
- **Laptop**: Power-optimized without resource-intensive tools
- **Graphics**: Automatic Intel or NVIDIA configuration
- **Conditional features**: Based on machine type and requirements

### Auto-Update System
- **GitHub Actions**: Automatically notify machines when configuration changes
- **Webhook Listener**: Real-time updates when changes are pushed
- **Offline Recovery**: Machines catch up when they reconnect
- **Manual Control**: Enable/disable auto-updates as needed
- **Desktop Notifications**: Stay informed about update status

See [AUTO-UPDATER.md](AUTO-UPDATER.md) for detailed information.

### External Dependencies
- **ZSH/P10k**: [My-ZshP10k-Nix](https://github.com/Michael-K-Williams/My-ZshP10k-Nix)
- **Claude Code**: [Claude-Code-Nix](https://github.com/Michael-K-Williams/Claude-Code-Nix)
- **EDHM**: [EDHM-Nix](https://github.com/Brighter-Applications/EDHM-Nix)
- **EDMC**: [EDMC-Nix](https://github.com/Brighter-Applications/EDMC-Nix)
- **VSCode**: [VSCode-mutable](https://github.com/Michael-K-Williams/VSCode-mutable)

### Included Software
- **Desktop Environment**: KDE Plasma 6 with SDDM
- **Shell**: Zsh with Powerlevel10k theme
- **Development**: Git, VSCode, Claude Code
- **Applications**: Firefox, Alacritty, Vesktop, Spotify
- **Gaming**: Elite Dangerous tools (desktop only)
- **System**: Flatpak support, comprehensive font collection

## Machine Configuration

Create machine-specific configurations in the `machines/` directory:

```nix
{
  hostName = "Katnix-YourMachine";
  userName = "yourusername";
  userDescription = "Your Name";
  backgroundImagePath = ./kat.png;
  
  hardwareImports = [
    ./intel-graphics.nix    # or ./nvidia.nix
  ];
  
  includeEliteDangerous = true;  # or false for laptops
}
```

## Updating

To update your system:

```bash
cd ~/nixos
nix flake update                                    # Update inputs
nixos-rebuild switch --flake .#YourMachineName     # Rebuild system
```

Example for desktop:
```bash
cd ~/nixos
nixos-rebuild switch --flake .#KatnixDesktop
```

## Customization

### Adding Packages
Edit `modules/packages.nix` to add system packages.

### Modifying Services
Update the relevant module files for service configurations.

### New Machine Types
Create new machine configurations and update the flake inputs.

### Custom Modules
Add new modules to the `modules/` directory and import them in `configuration.nix`.

## Contributing

Feel free to submit issues and pull requests for improvements!

## License

This project is open source and available under the MIT License.
