{ config, pkgs, machineConfig, ... }:
{
  # Elite Dangerous applications - conditionally enabled
  programs = {
    edhm.enable = machineConfig.includeEliteDangerous or false;
    edmc.enable = machineConfig.includeEliteDangerous or false;
  };
}
