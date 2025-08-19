{ config, pkgs, machineConfig, ... }:
{
  systemd.services.katnix-auto-update = {
    description = "Automatic Katnix Update Service";
    path = with pkgs; [ git nix sudo ];
    
    serviceConfig = {
      Type = "oneshot";
      User = machineConfig.userName;
      WorkingDirectory = "/home/${machineConfig.userName}/nixos";
      Environment = [
        "HOME=/home/${machineConfig.userName}"
        "USER=${machineConfig.userName}"
      ];
    };
    
    script = ''
      cd /home/${machineConfig.userName}/nixos
      /home/${machineConfig.userName}/.local/bin/katnix-update
    '';
  };

  systemd.timers.katnix-auto-update = {
    description = "Timer for Katnix Auto Updates";
    wantedBy = [ "timers.target" ];
    
    timerConfig = {
      OnCalendar = [ "*-*-* 07:00:00" "*-*-* 19:00:00" ];
      Persistent = true;
      RandomizedDelaySec = "5min";
    };
  };
}