{ config, pkgs, machineConfig, lib, ... }:

let
  # Script to check for updates and apply them
  updateChecker = pkgs.writeScriptBin "katnix-update-checker" ''
    #!${pkgs.bash}/bin/bash
    
    CONFIG_DIR="${config.users.users.${machineConfig.userName}.home}/nixos"
    LAST_UPDATE_FILE="/var/lib/katnix-updater/last-update"
    LOG_FILE="/var/log/katnix-updater.log"
    
    log_message() {
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        echo "[$timestamp] $1" | tee -a "$LOG_FILE"
    }
    
    # Ensure directories exist
    mkdir -p "$(dirname "$LAST_UPDATE_FILE")"
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Wait for network connectivity
    log_message "Checking for network connectivity..."
    for i in {1..30}; do
        if ${pkgs.curl}/bin/curl -s --max-time 5 https://github.com >/dev/null 2>&1; then
            log_message "Network connectivity confirmed"
            break
        fi
        if [ $i -eq 30 ]; then
            log_message "Network connectivity timeout - skipping update check"
            exit 0
        fi
        sleep 2
    done
    
    cd "$CONFIG_DIR" || exit 1
    
    # Fetch latest information
    log_message "Fetching latest repository information..."
    ${pkgs.git}/bin/git fetch origin main
    
    # Get local and remote commit hashes
    LOCAL_COMMIT=$(${pkgs.git}/bin/git rev-parse HEAD)
    REMOTE_COMMIT=$(${pkgs.git}/bin/git rev-parse origin/main)
    
    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        log_message "Updates available (local: $LOCAL_COMMIT, remote: $REMOTE_COMMIT)"
        
        # Show what changed
        ${pkgs.git}/bin/git log --oneline "$LOCAL_COMMIT..$REMOTE_COMMIT" | while read line; do
            log_message "  - $line"
        done
        
        # Create notification for the user
        ${pkgs.libnotify}/bin/notify-send \
            "Katnix Updates Available" \
            "System configuration has been updated. Applying changes automatically..." \
            --icon=software-update-available \
            --urgency=normal \
            --app-name="Katnix Updater" || true
        
        log_message "Applying updates automatically..."
        
        # Pull changes
        if ! ${pkgs.git}/bin/git pull origin main; then
            log_message "Git pull failed"
            exit 1
        fi
        
        # Update flake inputs
        if ! ${pkgs.nix}/bin/nix flake update; then
            log_message "Flake update failed"
            exit 1
        fi
        
        # Rebuild system
        if sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ".#default" --impure; then
            log_message "System update completed successfully"
            echo "$(date +%s)" > "$LAST_UPDATE_FILE"
            
            ${pkgs.libnotify}/bin/notify-send \
                "Katnix Update Complete" \
                "System has been successfully updated and rebuilt." \
                --icon=software-update-available \
                --urgency=normal \
                --app-name="Katnix Updater" || true
        else
            log_message "System update failed during rebuild"
            ${pkgs.libnotify}/bin/notify-send \
                "Katnix Update Failed" \
                "System update encountered an error during rebuild. Check logs for details." \
                --icon=dialog-error \
                --urgency=critical \
                --app-name="Katnix Updater" || true
            exit 1
        fi
    else
        log_message "System is up to date"
    fi
  '';

in {
  # Main update service
  systemd.services.katnix-update-checker = {
    description = "Check for Katnix configuration updates and apply them";
    after = [ "network-online.target" "systemd-tmpfiles-setup.service" ];
    wants = [ "network-online.target" "systemd-tmpfiles-setup.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      User = machineConfig.userName;
      Group = "users";
      ExecStart = "${updateChecker}/bin/katnix-update-checker";
      Environment = [ "PATH=${pkgs.lib.makeBinPath [ pkgs.git pkgs.nix pkgs.nixos-rebuild pkgs.coreutils pkgs.libnotify ]}" ];
      
      # Ensure directories exist before running
      ExecStartPre = [
        "+${pkgs.coreutils}/bin/mkdir -p /var/lib/katnix-updater"
        "+${pkgs.coreutils}/bin/chown ${machineConfig.userName}:users /var/lib/katnix-updater"
        "+${pkgs.coreutils}/bin/touch /var/log/katnix-updater.log"  
        "+${pkgs.coreutils}/bin/chown ${machineConfig.userName}:users /var/log/katnix-updater.log"
      ];
      
      # Security settings  
      NoNewPrivileges = false;  # Need privileges for ExecStartPre commands
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/log" "/var/lib/katnix-updater" "${config.users.users.${machineConfig.userName}.home}/nixos" ];
    };
  };

  # Timer to run every 30 minutes at :00 and :30
  systemd.timers.katnix-update-timer = {
    description = "Timer for Katnix update checker - runs every 30 minutes";
    wantedBy = [ "timers.target" ];
    
    timerConfig = {
      OnCalendar = "*:00/30:00";  # Every 30 minutes at :00 and :30
      Persistent = true;
      RandomizedDelaySec = "60";  # Random delay up to 1 minute to avoid GitHub rate limits
      Unit = "katnix-update-checker.service";
    };
  };

  # Check for updates on boot (after 5 minutes to let system settle)
  systemd.services.katnix-boot-update-check = {
    description = "Check for Katnix updates on boot";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl start katnix-update-checker.service";
      RemainAfterExit = true;
    };
  };

  systemd.timers.katnix-boot-update-timer = {
    description = "Delayed boot update check";
    after = [ "katnix-boot-update-check.service" ];
    
    timerConfig = {
      OnBootSec = "5min";  # Check 5 minutes after boot
      Unit = "katnix-update-checker.service";
    };
    
    wantedBy = [ "timers.target" ];
  };

  # Create log directory and permissions
  systemd.tmpfiles.rules = [
    "d /var/log 0755 root root -"
    "f /var/log/katnix-updater.log 0644 ${machineConfig.userName} ${machineConfig.userName} -"
    "d /var/lib/katnix-updater 0755 ${machineConfig.userName} ${machineConfig.userName} -"
  ];

  # Add sudo permissions for nixos-rebuild
  security.sudo.extraRules = [{
    users = [ machineConfig.userName ];
    commands = [{
      command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];
}
