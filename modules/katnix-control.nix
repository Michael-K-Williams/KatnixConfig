{ config, pkgs, machineConfig, ... }:

let
  katnixControl = pkgs.writeScriptBin "katnix-control" ''
    #!${pkgs.bash}/bin/bash
    
    # Katnix Auto-Updater Control Script
    
    show_help() {
        cat << EOF
    Katnix Auto-Updater Control
    
    Usage: katnix-control [COMMAND]
    
    Commands:
        status      Show updater service status
        logs        Show updater logs
        enable      Enable auto-updates
        disable     Disable auto-updates
        check       Manually check for updates
        update      Manually trigger update
        restart     Restart webhook listener
        help        Show this help message
    
    Examples:
        katnix-control status       # Check if services are running
        katnix-control logs         # View recent update logs
        katnix-control disable      # Disable automatic updates
        katnix-control check        # Check for updates now
    EOF
    }
    
    show_status() {
        echo "=== Katnix Auto-Updater Status ==="
        echo
        echo "Webhook Listener:"
        systemctl --no-pager status katnix-webhook-listener.service
        echo
        echo "Update Checker Timer:"
        systemctl --no-pager status katnix-update-checker.timer
        echo
        echo "Auto-Update Setting:"
        if [ "''${KATNIX_AUTO_UPDATE:-true}" = "true" ]; then
            echo "  ✅ Enabled"
        else
            echo "  ❌ Disabled"
        fi
    }
    
    show_logs() {
        echo "=== Katnix Updater Logs (last 50 lines) ==="
        if [ -f /var/log/katnix-updater.log ]; then
            tail -n 50 /var/log/katnix-updater.log
        else
            echo "No logs found"
        fi
    }
    
    enable_auto_update() {
        echo "Enabling auto-updates..."
        echo "KATNIX_AUTO_UPDATE=true" | sudo tee /etc/environment.d/katnix-updater.conf > /dev/null
        echo "✅ Auto-updates enabled. Changes will take effect after next login or reboot."
    }
    
    disable_auto_update() {
        echo "Disabling auto-updates..."
        echo "KATNIX_AUTO_UPDATE=false" | sudo tee /etc/environment.d/katnix-updater.conf > /dev/null
        echo "❌ Auto-updates disabled. Changes will take effect after next login or reboot."
        echo "Note: You can still manually update using 'katnix-control update'"
    }
    
    check_updates() {
        echo "Checking for updates..."
        systemctl start katnix-update-checker.service
        echo "Check complete. Use 'katnix-control logs' to see results."
    }
    
    manual_update() {
        echo "Starting manual update..."
        cd ${config.users.users.${machineConfig.userName}.home}/nixos || {
            echo "❌ Config directory not found"
            exit 1
        }
        
        echo "Pulling latest changes..."
        git pull origin main
        
        echo "Updating flake inputs..."
        nix flake update
        
        echo "Rebuilding system..."
        hostname_key=$(echo "${machineConfig.hostName}" | tr '[:upper:]' '[:lower:]' | sed 's/-//g')
        if sudo nixos-rebuild switch --flake ".#$hostname_key"; then
            echo "✅ Update completed successfully"
        else
            echo "❌ Update failed"
            exit 1
        fi
    }
    
    restart_services() {
        echo "Restarting Katnix updater services..."
        sudo systemctl restart katnix-webhook-listener.service
        sudo systemctl restart katnix-update-checker.timer
        echo "✅ Services restarted"
    }
    
    case "''${1:-help}" in
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        enable)
            enable_auto_update
            ;;
        disable)
            disable_auto_update
            ;;
        check)
            check_updates
            ;;
        update)
            manual_update
            ;;
        restart)
            restart_services
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use 'katnix-control help' for usage information"
            exit 1
            ;;
    esac
  '';
in {
  environment.systemPackages = [ katnixControl ];
}
