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
        check       Manually check for updates now
        update      Manually trigger update
        restart     Restart update timer
        help        Show this help message
    
    Examples:
        katnix-control status       # Check if services are running
        katnix-control logs         # View recent update logs
        katnix-control check        # Check for updates immediately
        katnix-control update       # Force update even if no changes
    EOF
    }
    
    show_status() {
        echo "=== Katnix Auto-Updater Status ==="
        echo
        echo "Update Timer:"
        systemctl --no-pager status katnix-update-timer.timer
        echo
        echo "Last Update Check:"
        systemctl --no-pager status katnix-update-checker.service | head -20
        echo
        echo "Timer Schedule:"
        systemctl list-timers katnix-update-timer.timer
    }
    
    show_logs() {
        echo "=== Katnix Updater Logs (last 50 lines) ==="
        if [ -f /var/log/katnix-updater.log ]; then
            tail -n 50 /var/log/katnix-updater.log
        else
            echo "No logs found"
        fi
        echo
        echo "=== Recent Systemd Journal Entries ==="
        journalctl -u katnix-update-checker.service -n 20 --no-pager
    }
    
    check_updates() {
        echo "🔍 Checking for updates immediately..."
        systemctl start katnix-update-checker.service
        echo "✅ Update check started. Use 'katnix-control logs' to see results."
        echo "💡 You can also follow live: journalctl -f -u katnix-update-checker.service"
    }
    
    manual_update() {
        echo "🚀 Starting manual update..."
        cd ${config.users.users.${machineConfig.userName}.home}/nixos || {
            echo "❌ Config directory not found"
            exit 1
        }
        
        echo "📥 Pulling latest changes..."
        git pull origin main
        
        echo "🔄 Updating flake inputs..."
        nix flake update
        
        echo "🔨 Rebuilding system..."
        hostname_key=$(echo "${machineConfig.hostName}" | tr '[:upper:]' '[:lower:]' | sed 's/-//g')
        if sudo nixos-rebuild switch --flake ".#$hostname_key"; then
            echo "✅ Update completed successfully"
            echo "$(date +%s)" | sudo tee /var/lib/katnix-updater/last-update > /dev/null
        else
            echo "❌ Update failed"
            exit 1
        fi
    }
    
    restart_services() {
        echo "🔄 Restarting Katnix updater services..."
        sudo systemctl restart katnix-update-timer.timer
        echo "✅ Timer restarted. Next check will run at scheduled time."
        systemctl list-timers katnix-update-timer.timer
    }
    
    case "''${1:-help}" in
        status)
            show_status
            ;;
        logs)
            show_logs
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
            echo "❌ Unknown command: $1"
            echo "Use 'katnix-control help' for usage information"
            exit 1
            ;;
    esac
  '';
in {
  environment.systemPackages = [ katnixControl ];
}
