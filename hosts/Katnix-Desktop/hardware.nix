# Hardware configuration for default host
# This is a placeholder - replace with your actual hardware configuration
# Generate it by running: sudo nixos-generate-config --show-hardware-config > hardware.nix

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # PLACEHOLDER - Replace this entire file with your actual hardware configuration
  # You can generate it by running: sudo nixos-generate-config --show-hardware-config
  
  # Basic placeholder configuration
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];  # Change to "kvm-amd" if using AMD CPU
  boot.extraModulePackages = [ ];

  # File systems - REPLACE WITH YOUR ACTUAL CONFIGURATION
  # Uncomment and modify these lines with your actual UUIDs:
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/YOUR-ROOT-UUID-HERE";
  #   fsType = "ext4";
  # };
  # 
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/YOUR-BOOT-UUID-HERE";
  #   fsType = "vfat";
  # };

  # Swap - REPLACE WITH YOUR ACTUAL CONFIGURATION
  # swapDevices = [ { device = "/dev/disk/by-uuid/YOUR-SWAP-UUID-HERE"; } ];

  # Networking
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware; # For AMD CPUs
}