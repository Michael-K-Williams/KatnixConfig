# Integration with KatnixConfig

This document explains how to integrate VSCode-Nix with your existing KatnixConfig modular setup to get the FHS environment functionality.

## Method 1: Overlay Approach (Recommended)

### 1. Update your flake.nix

Add VSCode-Nix as an input to your KatnixConfig flake.nix:

```nix
inputs = {
  # ... your existing inputs ...
  vscode-nix = {
    url = "github:Michael-K-Williams/VSCode-mutable/main";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### 2. Add the overlay to configuration.nix

In your `configuration.nix`, add the VSCode-Nix overlay:

```nix
# Apply overlays
nixpkgs.overlays = [
  (inputs.claude-code.overlays.default or (_: _: {}))
  inputs.vscode-nix.overlays.default  # Add this line
];
```

This will automatically replace the regular `vscode` package in your `modules/packages.nix` with the FHS environment version.

### 3. Keep your existing vscode-mutable setup

Your existing configuration in `configuration.nix` can stay the same:

```nix
# VSCode Mutable Installation
programs.vscode-mutable = {
  enable = true;
  userName = machineConfig.userName;
};
```

## Method 2: Direct Module Import

### 1. Update flake inputs (same as Method 1)

### 2. Add the module to your flake outputs

In your flake.nix outputs, add the VSCode-Nix module:

```nix
modules = [
  ./configuration.nix
  home-manager.nixosModules.home-manager
  edhm.nixosModules.default
  edmc.nixosModules.default
  vscode-mutable.nixosModules.default
  vscode-nix.nixosModules.default  # Add this line
  # ... rest of your modules
];
```

### 3. Remove regular vscode from packages.nix

Remove `vscode` from your `modules/packages.nix` systemPackages list since it will be provided by the FHS environment.

## What This Gives You

✅ **FHS Environment**: Complete library support for all VSCode extensions  
✅ **Mutable Installation**: Extensions can modify core VSCode files  
✅ **System Integration**: Proper desktop entries and activation scripts  
✅ **All Libraries**: X11, GTK, audio, development tools, and comprehensive fonts  
✅ **Drop-in Replacement**: Works with your existing packages and setup

## Testing

After applying these changes:

1. Run `katnix-switch` to rebuild your system
2. Test that `code` command works
3. Verify extensions that modify core files now work properly
4. Check that all fonts and libraries are available

The FHS environment provides the exact same functionality as your backup configuration but integrated cleanly with your modular flake setup.