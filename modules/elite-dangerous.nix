{ config, pkgs, machineConfig, ... }:
{
  # Elite Dangerous applications - conditionally enabled based on machine type
  programs = {
    edhm.enable = machineConfig.includeEliteDangerous or false;
    edmc.enable = machineConfig.includeEliteDangerous or false;
  };
}
