#!/usr/bin/env bash

# KatNix Installer - Downloads KatNix configuration to ~/nixos/
# Usage: curl -sSL https://raw.githubusercontent.com/Michael-K-Williams/KatnixConfig/Hyprland/install-katnix.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on NixOS
if ! grep -q "ID=nixos" /etc/os-release 2>/dev/null; then
    print_error "This installer is designed for NixOS only!"
    exit 1
fi

print_status "KatNix Configuration Installer"
echo "==============================="

# Check if git is available, install temporarily if needed
if ! command -v git &> /dev/null; then
    print_warning "Git not found. Installing git temporarily via nix-shell..."
    
    # Function to run git commands in nix-shell
    run_git() {
        nix-shell -p git --run "$*"
    }
    
    # Test if nix-shell works
    if ! nix-shell -p git --run "git --version" &>/dev/null; then
        print_error "Failed to install git via nix-shell. Please ensure nix is properly configured."
        exit 1
    fi
    
    print_success "Git available via nix-shell"
    GIT_VIA_SHELL=true
else
    # Function to run git commands normally
    run_git() {
        git "$@"
    }
    
    print_success "Git found in system"
    GIT_VIA_SHELL=false
fi

# Set target directory
TARGET_DIR="$HOME/nixos"

# Handle existing directory
if [ -d "$TARGET_DIR" ]; then
    print_warning "Directory $TARGET_DIR already exists."
    
    # Check if it's a git repo
    if [ -d "$TARGET_DIR/.git" ]; then
        print_status "Found existing git repository. Creating backup..."
        BACKUP_DIR="${TARGET_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
        mv "$TARGET_DIR" "$BACKUP_DIR"
        print_success "Backed up to $BACKUP_DIR"
    else
        print_warning "Existing directory is not a git repo."
        read -p "Do you want to remove it and continue? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Installation cancelled by user."
            exit 1
        fi
        rm -rf "$TARGET_DIR"
        print_success "Removed existing directory"
    fi
fi

# Clone the repository
print_status "Downloading KatNix configuration..."

if [ "$GIT_VIA_SHELL" = true ]; then
    nix-shell -p git --run "git clone -b Hyprland https://github.com/Michael-K-Williams/KatnixConfig.git '$TARGET_DIR'"
else
    git clone -b Hyprland https://github.com/Michael-K-Williams/KatnixConfig.git "$TARGET_DIR"
fi

if [ $? -eq 0 ]; then
    print_success "KatNix configuration downloaded to $TARGET_DIR"
else
    print_error "Failed to clone repository"
    exit 1
fi

# Navigate to the directory
cd "$TARGET_DIR"

print_success "Installation complete!"
echo
print_status "Next steps:"
echo "1. Generate hardware configuration for your machine:"
echo "   sudo nixos-generate-config --show-hardware-config > hosts/Katnix-Laptop/hardware.nix"
echo "   # Or for desktop: hosts/Katnix-Desktop/hardware.nix"
echo
echo "2. Customize variables in hosts/*/variables.nix if needed"
echo
echo "3. Build and switch to the configuration:"
echo "   sudo nixos-rebuild switch .#Katnix-Laptop"
echo "   # Or: sudo nixos-rebuild switch .#Katnix-Desktop"
echo
print_status "Available configurations:"
echo "  - Katnix-Laptop  (for laptops)"
echo "  - Katnix-Desktop (for desktops)"
echo "  - default        (legacy/fallback)"
echo
if [ "$GIT_VIA_SHELL" = true ]; then
    print_status "Note: Git was installed temporarily. Consider adding it to your system configuration."
fi
echo
print_success "Happy NixOS-ing! 🐱"