{ config, pkgs, machineConfig, lib, ... }:

let
  # Webhook listener script
  webhookListener = pkgs.writeScriptBin "katnix-webhook-listener" ''
    #!${pkgs.bash}/bin/bash
    
    # Simple HTTP server to listen for GitHub webhooks
    ${pkgs.python3}/bin/python3 << 'EOF'
    import http.server
    import socketserver
    import json
    import subprocess
    import os
    import sys
    import hashlib
    import hmac
    from urllib.parse import urlparse, parse_qs
    
    PORT = 8080
    CONFIG_DIR = "${config.users.users.${machineConfig.userName}.home}/nixos"
    LOG_FILE = "/var/log/katnix-updater.log"
    
    def log_message(msg):
        timestamp = subprocess.check_output(["date", "+%Y-%m-%d %H:%M:%S"]).decode().strip()
        with open(LOG_FILE, "a") as f:
            f.write(f"[{timestamp}] {msg}\n")
        print(f"[{timestamp}] {msg}")
    
    def verify_signature(payload, signature, secret):
        """Verify GitHub webhook signature"""
        if not signature:
            return False
        
        expected = hmac.new(
            secret.encode('utf-8'),
            payload,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(f"sha256={expected}", signature)
    
    def update_system(notification_data):
        """Update the Katnix system"""
        try:
            log_message(f"Starting update for commit {notification_data.get('commit_sha', 'unknown')}")
            
            # Change to config directory
            os.chdir(CONFIG_DIR)
            
            # Pull latest changes
            result = subprocess.run(["git", "pull"], capture_output=True, text=True)
            if result.returncode != 0:
                log_message(f"Git pull failed: {result.stderr}")
                return False
            
            # Update flake inputs
            result = subprocess.run(["nix", "flake", "update"], capture_output=True, text=True)
            if result.returncode != 0:
                log_message(f"Flake update failed: {result.stderr}")
                return False
            
            # Get hostname for rebuild
            hostname = "${machineConfig.hostName}".replace("-", "").lower()
            
            # Rebuild system
            rebuild_cmd = ["sudo", "nixos-rebuild", "switch", "--flake", f".#{hostname}"]
            result = subprocess.run(rebuild_cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                log_message("System update completed successfully")
                return True
            else:
                log_message(f"System rebuild failed: {result.stderr}")
                return False
                
        except Exception as e:
            log_message(f"Update failed with exception: {str(e)}")
            return False
    
    class WebhookHandler(http.server.BaseHTTPRequestHandler):
        def do_POST(self):
            if self.path == "/webhook/katnix-update":
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                
                # Verify signature (optional - comment out if not using secrets)
                # signature = self.headers.get('X-Hub-Signature-256')
                # if not verify_signature(post_data, signature, os.environ.get('KATNIX_WEBHOOK_SECRET', '')):
                #     self.send_response(401)
                #     self.end_headers()
                #     log_message("Webhook signature verification failed")
                #     return
                
                try:
                    notification = json.loads(post_data.decode('utf-8'))
                    log_message(f"Received update notification: {notification.get('commit_message', 'No message')}")
                    
                    # Update system in background
                    if update_system(notification):
                        self.send_response(200)
                        self.send_header('Content-type', 'application/json')
                        self.end_headers()
                        self.wfile.write(json.dumps({"status": "success", "message": "Update started"}).encode())
                    else:
                        self.send_response(500)
                        self.send_header('Content-type', 'application/json')
                        self.end_headers()
                        self.wfile.write(json.dumps({"status": "error", "message": "Update failed"}).encode())
                        
                except Exception as e:
                    log_message(f"Error processing webhook: {str(e)}")
                    self.send_response(400)
                    self.end_headers()
            else:
                self.send_response(404)
                self.end_headers()
        
        def log_message(self, format, *args):
            # Suppress default HTTP logging
            pass
    
    log_message("Starting Katnix webhook listener on port 8080")
    
    with socketserver.TCPServer(("", PORT), WebhookHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            log_message("Webhook listener stopped")
            sys.exit(0)
    EOF
  '';

  # Script to check for updates on boot/network change
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
    
    # Get last update timestamp
    LAST_UPDATE="0"
    if [ -f "$LAST_UPDATE_FILE" ]; then
        LAST_UPDATE=$(cat "$LAST_UPDATE_FILE")
    fi
    
    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        log_message "Updates available (local: $LOCAL_COMMIT, remote: $REMOTE_COMMIT)"
        
        # Show what changed
        ${pkgs.git}/bin/git log --oneline "$LOCAL_COMMIT..$REMOTE_COMMIT" | while read line; do
            log_message "  - $line"
        done
        
        # Create notification for the user
        ${pkgs.libnotify}/bin/notify-send \
            "Katnix Updates Available" \
            "System configuration has been updated. Click to apply changes." \
            --icon=software-update-available \
            --urgency=normal \
            --app-name="Katnix Updater" \
            --action="apply=Apply Updates" \
            --action="dismiss=Dismiss" || true
        
        # Auto-update if configured (could be made optional)
        if [ "''${KATNIX_AUTO_UPDATE:-true}" = "true" ]; then
            log_message "Auto-update enabled, applying changes..."
            
            # Pull changes
            ${pkgs.git}/bin/git pull origin main
            
            # Update flake
            ${pkgs.nix}/bin/nix flake update
            
            # Rebuild system
            hostname_key=$(echo "${machineConfig.hostName}" | tr '[:upper:]' '[:lower:]' | sed 's/-//g')
            if sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ".#$hostname_key"; then
                log_message "System update completed successfully"
                echo "$(date +%s)" > "$LAST_UPDATE_FILE"
                
                ${pkgs.libnotify}/bin/notify-send \
                    "Katnix Update Complete" \
                    "System has been successfully updated." \
                    --icon=software-update-available \
                    --urgency=normal \
                    --app-name="Katnix Updater" || true
            else
                log_message "System update failed"
                ${pkgs.libnotify}/bin/notify-send \
                    "Katnix Update Failed" \
                    "System update encountered an error. Check logs for details." \
                    --icon=dialog-error \
                    --urgency=critical \
                    --app-name="Katnix Updater" || true
            fi
        fi
    else
        log_message "System is up to date"
    fi
  '';

in {
  # Create the systemd services
  systemd.services.katnix-webhook-listener = {
    description = "Katnix Webhook Listener";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "katnix-updater";
      Group = "katnix-updater";
      ExecStart = "${webhookListener}/bin/katnix-webhook-listener";
      Restart = "always";
      RestartSec = 10;
      
      # Security settings
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/log" "/var/lib/katnix-updater" "${config.users.users.${machineConfig.userName}.home}/nixos" ];
    };
  };

  systemd.services.katnix-update-checker = {
    description = "Check for Katnix configuration updates";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      User = machineConfig.userName;
      ExecStart = "${updateChecker}/bin/katnix-update-checker";
      
      # Security settings
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/log" "/var/lib/katnix-updater" "${config.users.users.${machineConfig.userName}.home}/nixos" ];
    };
  };

  # Timer to run update checker periodically
  systemd.timers.katnix-update-checker = {
    description = "Timer for Katnix update checker";
    wantedBy = [ "timers.target" ];
    
    timerConfig = {
      OnBootSec = "2min";  # Check 2 minutes after boot
      OnUnitActiveSec = "30min";  # Check every 30 minutes
      Persistent = true;
    };
  };

  # Network connectivity trigger
  systemd.services.katnix-network-trigger = {
    description = "Trigger Katnix update check on network changes";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl start katnix-update-checker.service";
      RemainAfterExit = true;
    };
    
    wantedBy = [ "network-online.target" ];
  };

  # Create user for webhook service
  users.users.katnix-updater = {
    isSystemUser = true;
    group = "katnix-updater";
    home = "/var/lib/katnix-updater";
    createHome = true;
  };

  users.groups.katnix-updater = {};

  # Create log directory
  systemd.tmpfiles.rules = [
    "d /var/log 0755 root root -"
    "f /var/log/katnix-updater.log 0644 katnix-updater katnix-updater -"
    "d /var/lib/katnix-updater 0755 katnix-updater katnix-updater -"
  ];

  # Add sudo permissions for the update user
  security.sudo.extraRules = [{
    users = [ machineConfig.userName ];
    commands = [{
      command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  # Environment variables for configuration
  environment.variables = {
    KATNIX_AUTO_UPDATE = "true";  # Set to false to disable auto-updates
  };
  
  # Open firewall port for webhook (optional - only if you want external access)
  # networking.firewall.allowedTCPPorts = [ 8080 ];
}
