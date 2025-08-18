# Katnix Auto-Updater System

The Katnix configuration includes an automated update system that keeps all your machines synchronized with the latest configuration changes from GitHub.

## How It Works

### 1. **GitHub Actions Trigger**
When you push changes to the main branch, GitHub Actions:
- Detects configuration changes (`.nix` files, `flake.lock`, etc.)
- Attempts to notify all configured machines via webhook
- Creates a fallback notification artifact for offline machines

### 2. **Local Services**
Each machine runs several services:

#### **Webhook Listener** (`katnix-webhook-listener.service`)
- Listens on port 8080 for GitHub webhook notifications
- Automatically pulls changes and rebuilds the system
- Runs continuously in the background

#### **Update Checker** (`katnix-update-checker.service`)
- Periodically checks for updates (every 30 minutes)
- Runs automatically on boot and network reconnection
- Handles offline machines that missed webhook notifications

#### **Network Trigger** (`katnix-network-trigger.service`)
- Triggers update check when network connectivity is restored
- Ensures offline machines catch up when they come back online

## Configuration

### Machine List (GitHub Actions)
Edit `.github/workflows/notify-machines.yml` to add your machines:

```yaml
MACHINES=(
  "katnix-desktop:8080"
  "katnix-laptop:8080" 
  "katnix-server:8080"
  # Add more as needed
)
```

### Auto-Update Settings
Control automatic updates with environment variables:

```bash
# Enable auto-updates (default)
export KATNIX_AUTO_UPDATE=true

# Disable auto-updates (manual only)
export KATNIX_AUTO_UPDATE=false
```

## Usage

### Control Script
Use the `katnix-control` command to manage the updater:

```bash
# Check status of all services
katnix-control status

# View recent logs
katnix-control logs

# Enable/disable auto-updates
katnix-control enable
katnix-control disable

# Manually check for updates
katnix-control check

# Manually update now
katnix-control update

# Restart services
katnix-control restart
```

### Manual Updates
You can still update manually as before:

```bash
cd ~/nixos
git pull
nix flake update
nixos-rebuild switch --flake .#yourmachine
```

## Notifications

The system provides desktop notifications:
- **Updates Available**: When new changes are detected
- **Update Complete**: When automatic update succeeds  
- **Update Failed**: When automatic update encounters errors

## Logs

All updater activity is logged to `/var/log/katnix-updater.log`:

```bash
# View logs
tail -f /var/log/katnix-updater.log

# Or use the control script
katnix-control logs
```

## Security

### Webhook Security (Optional)
For additional security, you can enable webhook signature verification:

1. Create a secret in your GitHub repository settings
2. Uncomment the signature verification lines in the webhook listener
3. Set the `KATNIX_WEBHOOK_SECRET` environment variable

### Sudo Permissions
The updater requires sudo access for `nixos-rebuild`. This is configured automatically with NOPASSWD for the rebuild command only.

## Troubleshooting

### Common Issues

**Services not running:**
```bash
sudo systemctl status katnix-webhook-listener
sudo systemctl status katnix-update-checker.timer
```

**Network connectivity issues:**
```bash
# Test webhook endpoint
curl -X POST http://localhost:8080/webhook/katnix-update \
  -H "Content-Type: application/json" \
  -d '{"test": "message"}'
```

**Update failures:**
```bash
# Check logs for detailed error messages
katnix-control logs

# Try manual update to see specific errors
katnix-control update
```

### Offline Machines
Machines that are offline when updates are pushed will:
1. Check for updates when they boot up
2. Check for updates when network connectivity is restored
3. Check for updates every 30 minutes while online

### Disabling Auto-Updates
If you want to disable automatic updates but keep notifications:

```bash
katnix-control disable
```

This will:
- Stop automatic system rebuilds
- Continue checking for updates
- Show notifications about available updates
- Allow manual updates via `katnix-control update`

## Benefits

- **Always up-to-date**: All machines stay synchronized automatically
- **Offline resilience**: Machines catch up when they come back online  
- **Manual control**: Can disable auto-updates and update manually
- **Monitoring**: Comprehensive logging and status checking
- **Notifications**: Desktop alerts for update status
- **Secure**: Minimal sudo permissions, optional webhook signing

## Network Requirements

- **Outbound HTTPS**: For git pulls and flake updates
- **Inbound HTTP** (optional): For webhook notifications on port 8080
- **mDNS/Avahi**: For `.local` hostname resolution between machines
