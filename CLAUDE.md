# Claude Code Memory - VS Code Setup

## Issue
User had VS Code installed via mutable installation in NixOS but was getting library dependency errors:
- `libglib-2.0.so.0: cannot open shared object file: No such file or directory`
- Permission denied errors requiring sudo

## Root Cause
1. VS Code was installed via FHS environment but missing required shared libraries
2. VS Code files were owned by root instead of user, causing permission issues
3. Desktop entry was missing

## Solution Applied

### 1. Fixed FHS Environment Libraries
Added missing libraries to `buildFHSEnv` in `/home/thealtkitkat/nixos/configuration.nix`:
- `xorg.libXcomposite`
- `xorg.libXdamage` 
- `xorg.libXfixes`
- `xorg.libXrandr`
- `xorg.libxcb`
- `libxkbcommon`
- `systemd` (for libudev)
- `libgbm`
- `libGL`
- `polkit`
- `nodejs`, `python3`, `gcc`, `gnumake` (for native modules)

### 2. Fixed File Ownership
Changed activation script ownership from `root:wheel` to `thealtkitkat:users`:
```nix
chown -R thealtkitkat:users "$VSCODE_DIR"
```

### 3. Added Desktop Entry
Added desktop entry creation to activation script:
- Creates `/usr/share/applications/code.desktop`
- Updates desktop database with `update-desktop-database`

## Current Status
- VS Code launches successfully with `code` command
- Shows non-critical warnings about missing native keymapping module (safe to ignore)
- Desktop entry created but may need desktop session restart to appear
- All file permission issues resolved

## Key Commands
- Start VS Code: `code`
- Rebuild system: `katnix-switch` 
- Force VS Code reinstall: `sudo rm -rf /opt/vscode-mutable && katnix-switch`

## Files Modified
- `/home/thealtkitkat/nixos/configuration.nix` - Main NixOS configuration with FHS environment and VS Code installation

## Next Steps After Reboot
- Check if desktop entry appears in application menu
- If not, may need to manually refresh desktop environment cache