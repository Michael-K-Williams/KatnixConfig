{ config, pkgs, machineConfig, ... }:
{
  # Networking configuration
  networking = {
    hostName = machineConfig.hostName;
    networkmanager.enable = true;
  };
}
