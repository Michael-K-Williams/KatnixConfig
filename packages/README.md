# VSCode-Nix

A NixOS package for installing Visual Studio Code in a mutable way with FHS environment support, allowing extensions to modify core VS Code files.

## Features

- **Complete FHS Environment**: Provides all necessary libraries for VS Code and extensions
- **Mutable Installation**: Allows extensions to modify VS Code core files
- **System Integration**: Automatic desktop entries and activation scripts
- **Comprehensive Libraries**: X11, GTK, audio, development tools, and fonts
- **Drop-in Replacement**: Matches the exact functionality from NixOS system configurations

## Quick Start

### Method 1: Direct Package Import (Recommended)

Add to your NixOS configuration:

```nix
{ config, pkgs, ... }:

let
  vscode-nix = pkgs.callPackage /path/to/VSCode-Nix { userName = "yourusername"; };
in
{
  environment.systemPackages = [
    vscode-nix.vscode-fhs-complete  # FHS environment with all libraries
  ];

  # Mutable installation with system activation
  system.activationScripts.vscode-mutable = vscode-nix.vscode-activation;
  
  nixpkgs.config.allowUnfree = true;
}
```

### Method 2: Traditional Usage

### Direct NixOS Module Import

You can import the module directly in your NixOS configuration without adding it as a flake input:

```nix
{
  imports = [
    (builtins.getFlake "github:Michael-K-Williams/VSCode-mutable/main").nixosModules.default
  ];

  programs.vscode-mutable = {
    enable = true;
    userName = "yourusername";
  };
}
```

### As a Flake Input

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    vscode-mutable = {
      url = "github:Michael-K-Williams/VSCode-mutable/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, vscode-mutable, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        vscode-mutable.nixosModules.default
        {
          programs.vscode-mutable = {
            enable = true;
            userName = "yourusername";
          };
        }
      ];
    };
  };
}
```

## Configuration Options

- `userName`: Username for VS Code installation (required)
- `installDir`: Installation directory (default: `/opt/vscode-mutable`)
- `vscodeUrl`: Primary download URL
- `fallbackUrl`: Fallback download URL if primary fails
- `fonts`: List of fonts to install for VS Code

## Why Mutable Installation?

Some VS Code extensions require modifying VS Code's actual application files to function properly, such as extensions that provide custom image backgrounds, theming modifications, or other deep UI customizations. The traditional Nix store approach makes these files read-only, preventing such extensions from working.

This mutable installation approach allows:

- Extensions that modify VS Code's core files (like image background extensions)
- Deep theming and UI customization extensions
- Extensions and settings to be installed and updated normally
- Settings and configurations to persist
- VS Code to update itself through its built-in update mechanism
- Better integration with system desktop environments

## FHS Environment Wrapper

The FHS wrapper (`vscode-fhs`) provides a comprehensive runtime environment with all necessary libraries including:

**Core System Libraries:**
- `stdenv.cc.cc.lib`, `zlib`, `openssl`, `curl`, `expat`, `libxml2`, `libxslt`

**Graphics & Display:**
- `fontconfig`, `freetype`, `libxkbcommon`, `libGL`, `mesa`, `libgbm`, `vulkan-loader`, `libdrm`

**X11/Xorg Libraries:**
- Complete X11 library set including `libX11`, `libXext`, `libXrender`, `libXtst`, `libXi`, `libXcomposite`, `libXdamage`, `libXfixes`, `libXrandr`, `libxcb`

**GTK/GUI Libraries:**
- `systemd`, `glib`, `gtk3`, `pango`, `cairo`, `gdk-pixbuf`, `atk`

**Audio & System Services:**
- `nss`, `nspr`, `alsa-lib`, `at-spi2-core`, `cups`, `dbus`, `polkit`

**Development Tools:**
- `nodejs`, `python3`, `gcc`, `gnumake`

**Comprehensive Font Support:**
- Google Fonts, Source Code Pro, JetBrains Mono, Ubuntu Font Family
- Noto Fonts (including CJK and Emoji support)
- Nerd Fonts variants (FiraCode, JetBrains Mono, Ubuntu Mono, etc.)
- Material Design Icons, Font Awesome, Powerline Fonts

## License

This project is licensed under the MIT License.
