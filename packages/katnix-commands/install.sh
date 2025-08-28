#!/usr/bin/env bash

# Katnix Installer - Interactive NixOS Configuration Installer
# This script helps set up a new Katnix system with customizable options

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
KATNIX_CONFIG_REPO="https://github.com/Michael-K-Williams/KatnixConfig.git"
CONFIG_DIR="$HOME/nixos"
HOSTNAME=""
MACHINE_TYPE=""
GRAPHICS_TYPE=""
USERNAME=$(whoami)

# Helper functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    Katnix NixOS Installer      ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_info "Run it as your regular user. It will prompt for sudo when needed."
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install git first:"
        echo "  nix-shell -p git"
        exit 1
    fi
    
    if ! command -v nix &> /dev/null; then
        print_error "Nix is not installed. This script requires NixOS."
        exit 1
    fi
    
    if [[ ! -f /etc/nixos/hardware-configuration.nix ]]; then
        print_error "This doesn't appear to be a NixOS system or hardware-configuration.nix is missing!"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Get hostname from user
get_hostname() {
    echo ""
    echo -e "${BLUE}Hostname Configuration${NC}"
    echo "Please enter a hostname for this machine (will be prefixed with 'Katnix-'):"
    echo "Examples: Desktop, Laptop, Server, etc."
    echo ""
    
    while true; do
        read -p "Enter hostname suffix: " hostname_suffix
        
        if [[ -z "$hostname_suffix" ]]; then
            print_error "Hostname cannot be empty!"
            continue
        fi
        
        if [[ ! "$hostname_suffix" =~ ^[a-zA-Z0-9-]+$ ]]; then
            print_error "Hostname can only contain letters, numbers, and hyphens!"
            continue
        fi
        
        HOSTNAME="Katnix-$hostname_suffix"
        echo ""
        print_info "Hostname will be: $HOSTNAME"
        read -p "Is this correct? (y/n): " confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            break
        fi
    done
    
    print_success "Hostname configured: $HOSTNAME"
}

# Get machine type from user
get_machine_type() {
    echo ""
    echo -e "${BLUE}Machine Type Configuration${NC}"
    echo "Select your machine type:"
    echo "1) Desktop - Includes EDHM and EDMC (Elite Dangerous tools)"
    echo "2) Laptop  - Excludes EDHM and EDMC for better battery life"
    echo ""
    
    while true; do
        read -p "Enter choice (1 or 2): " choice
        
        case $choice in
            1)
                MACHINE_TYPE="desktop"
                print_success "Machine type: Desktop (with Elite Dangerous tools)"
                break
                ;;
            2)
                MACHINE_TYPE="laptop"
                print_success "Machine type: Laptop (minimal configuration)"
                break
                ;;
            *)
                print_error "Invalid choice! Please enter 1 or 2."
                ;;
        esac
    done
}

# Get graphics type from user
get_graphics_type() {
    echo ""
    echo -e "${BLUE}Graphics Configuration${NC}"
    echo "Select your graphics hardware:"
    echo "1) Intel Graphics"
    echo "2) NVIDIA Graphics"
    echo ""
    
    while true; do
        read -p "Enter choice (1 or 2): " choice
        
        case $choice in
            1)
                GRAPHICS_TYPE="intel"
                print_success "Graphics: Intel"
                break
                ;;
            2)
                GRAPHICS_TYPE="nvidia"
                print_success "Graphics: NVIDIA"
                break
                ;;
            *)
                print_error "Invalid choice! Please enter 1 or 2."
                ;;
        esac
    done
}

# Clone or update configuration
setup_config() {
    print_info "Setting up configuration in $CONFIG_DIR..."
    
    if [[ -d "$CONFIG_DIR" ]]; then
        print_warning "Directory $CONFIG_DIR already exists!"
        read -p "Do you want to remove it and start fresh? (y/n): " confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -rf "$CONFIG_DIR"
            print_info "Removed existing configuration directory"
        else
            print_error "Installation cancelled"
            exit 1
        fi
    fi
    
    print_info "Cloning Katnix configuration..."
    git clone "$KATNIX_CONFIG_REPO" "$CONFIG_DIR"
    cd "$CONFIG_DIR"
    
    # Copy hardware configuration from system
    print_info "Copying hardware configuration..."
    sudo cp /etc/nixos/hardware-configuration.nix "$CONFIG_DIR/"
    sudo chown "$USERNAME:users" "$CONFIG_DIR/hardware-configuration.nix"
    
    print_success "Configuration cloned successfully"
}

# Generate machine configuration
generate_machine_config() {
    print_info "Generating machine-specific configuration..."
    
    local machine_file="$CONFIG_DIR/machines/$(echo $HOSTNAME | tr '[:upper:]' '[:lower:]').nix"
    local hardware_imports=""
    
    # Set hardware imports based on graphics type
    if [[ "$GRAPHICS_TYPE" == "intel" ]]; then
        hardware_imports="    ./intel-graphics.nix"
    elif [[ "$GRAPHICS_TYPE" == "nvidia" ]]; then
        hardware_imports="    ./nvidia.nix"
    fi
    
    cat > "$machine_file" << EOF
{
  hostName = "$HOSTNAME";
  userName = "$USERNAME";
  userDescription = "Katnix User";
  backgroundImagePath = ./kat.png;
  
  # Hardware imports based on graphics type
  hardwareImports = [
$hardware_imports
  ];
  
  # Machine type configuration
  machineType = "$MACHINE_TYPE";
  includeEliteDangerous = $(if [[ "$MACHINE_TYPE" == "desktop" ]]; then echo "true"; else echo "false"; fi);
}
EOF

    print_success "Generated machine configuration: $machine_file"
}

# Update flake configuration
update_flake_config() {
    print_info "Updating flake configuration..."
    
    local hostname_key=$(echo $HOSTNAME | sed 's/-//g')
    local machine_import="./machines/$(echo $HOSTNAME | tr '[:upper:]' '[:lower:]').nix"
    
    # Check if the hostname already exists in flake.nix
    if grep -q "$hostname_key" "$CONFIG_DIR/flake.nix"; then
        print_info "Configuration for $hostname_key already exists in flake.nix"
    else
        # Add the new configuration to flake.nix after the existing configurations
        # Find the line with "nixosConfigurations = {" and add after existing entries
        local temp_file=$(mktemp)
        awk -v hostname="$hostname_key" -v machine_import="$machine_import" '
        /nixosConfigurations = \{/ { 
            print $0
            found = 1
            next
        }
        found && /\};$/ && !/^[[:space:]]*[^[:space:]].*=.*mkSystem/ {
            print "      " hostname " = mkSystem (import " machine_import ");"
            print $0
            found = 0
            next
        }
        { print }
        ' "$CONFIG_DIR/flake.nix" > "$temp_file"
        
        mv "$temp_file" "$CONFIG_DIR/flake.nix"
        print_success "Added $hostname_key configuration to flake.nix"
    fi
}

# Update configuration to conditionally include Elite Dangerous apps
update_elite_config() {
    print_info "Updating Elite Dangerous application configuration..."
    
    # Create a conditional configuration for Elite Dangerous apps
    local elite_config="$CONFIG_DIR/modules/elite-dangerous.nix"
    
    cat > "$elite_config" << 'EOF'
{ config, pkgs, machineConfig, ... }:
{
  # Elite Dangerous applications - conditionally enabled
  programs = {
    edhm.enable = machineConfig.includeEliteDangerous or false;
    edmc.enable = machineConfig.includeEliteDangerous or false;
  };
}
EOF

    # Update configuration.nix to include the new module
    if ! grep -q "./modules/elite-dangerous.nix" "$CONFIG_DIR/configuration.nix"; then
        sed -i '/\.\/modules\/users\.nix/a\    ./modules/elite-dangerous.nix' "$CONFIG_DIR/configuration.nix"
        
        # Remove the hardcoded Elite Dangerous programs from configuration.nix
        sed -i '/programs\.edhm\.enable = true;/d' "$CONFIG_DIR/configuration.nix"
        sed -i '/programs\.edmc\.enable = true;/d' "$CONFIG_DIR/configuration.nix"
        
        print_success "Elite Dangerous applications configured conditionally"
    fi
}

# Install system configuration
install_system() {
    print_info "Installing system configuration..."
    
    cd "$CONFIG_DIR"
    
    print_info "Updating flake lock..."
    nix flake update
    
    print_info "Building and switching to new configuration..."
    print_warning "This will require sudo access to install the system configuration"
    
    local hostname_key=$(echo $HOSTNAME | sed 's/-//g')
    
    # First try to build the configuration to catch any errors
    print_info "Building configuration..."
    nix build ".#nixosConfigurations.$hostname_key.config.system.build.toplevel"
    
    # If build succeeds, switch to it
    print_info "Switching to new configuration..."
    sudo nixos-rebuild switch --flake ".#$hostname_key"
    
    print_success "System configuration installed successfully!"
}

# Main installation process
main() {
    print_header
    
    check_root
    check_prerequisites
    get_hostname
    get_machine_type  
    get_graphics_type
    
    echo ""
    echo -e "${BLUE}Configuration Summary:${NC}"
    echo "  Hostname: $HOSTNAME"
    echo "  Machine Type: $MACHINE_TYPE"
    echo "  Graphics: $GRAPHICS_TYPE"
    echo "  Elite Dangerous Apps: $(if [[ "$MACHINE_TYPE" == "desktop" ]]; then echo "Enabled"; else echo "Disabled"; fi)"
    echo "  Configuration Directory: $CONFIG_DIR"
    echo ""
    
    read -p "Proceed with installation? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi
    
    setup_config
    generate_machine_config
    update_flake_config
    update_elite_config
    install_system
    
    echo ""
    print_success "Katnix installation completed!"
    print_info "Your system is now configured with your custom settings."
    print_info "Configuration is available at: $CONFIG_DIR"
    echo ""
    print_info "Future updates can be done with:"
    echo "  cd ~/nixos && nixos-rebuild switch --flake .#$(echo $HOSTNAME | sed 's/-//g')"
    echo ""
    print_warning "You may need to reboot to ensure all changes take effect."
}

# Run main function
main "$@"
