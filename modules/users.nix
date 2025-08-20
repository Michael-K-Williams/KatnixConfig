{ config, pkgs, machineConfig, ... }:
{
  # User configuration
  users.users.${machineConfig.userName} = {
    isNormalUser = true;
    description = machineConfig.userDescription;
    extraGroups = [ "networkmanager" "wheel" "plugdev" ];
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;
  
  # Default Shell
  users.defaultUserShell = pkgs.zsh;

  # Time Zone
  time.timeZone = "Europe/London";

  # Locale
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  console.keyMap = "uk";
}
