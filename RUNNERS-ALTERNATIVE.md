# GitHub Actions Self-Hosted Runner Alternative

If you prefer to use actual GitHub Actions runners instead of webhooks, here's how to set it up:

## Current Implementation (Webhooks)
What I built doesn't use runners - it's a webhook system:

1. **GitHub Actions** (on GitHub's servers) sends HTTP POST to your machines
2. **Your machines** listen on port 8080 and respond to notifications  
3. **No tokens or registration** needed

## Alternative: Self-Hosted Runners

### Setup Process

#### 1. Generate Runner Tokens
For each machine:
1. Repository Settings → Actions → Runners → "New self-hosted runner"
2. Select Linux x64
3. Save the provided token

#### 2. NixOS Module for Runners
```nix
{ config, pkgs, ... }:
{
  services.github-runners.katnix = {
    enable = true;
    url = "https://github.com/Michael-K-Williams/KatnixConfig";
    tokenFile = "/etc/github-runner-token";
    name = "katnix-${config.networking.hostName}";
    labels = [ "nixos" "katnix" config.networking.hostName ];
    extraLabels = [ "self-hosted" "linux" "x64" ];
  };

  # Secure token file
  systemd.tmpfiles.rules = [
    "f /etc/github-runner-token 0600 github-runner github-runner -"
  ];
}
```

#### 3. Workflow for Runners
```yaml
name: Deploy to Katnix Machines
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    strategy:
      matrix:
        runner: [katnix-desktop, katnix-laptop]
    runs-on: ${{ matrix.runner }}
    steps:
      - name: Update Katnix system
        run: |
          cd ~/nixos
          git pull origin main
          nix flake update
          sudo nixos-rebuild switch --flake .#$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/-//g')
```

## Comparison

### Webhook System (Current)
**✅ Pros:**
- No token management
- Zero configuration after install
- Handles offline machines automatically
- Simple HTTP requests

**❌ Cons:**  
- Custom implementation
- Requires port 8080 accessibility
- Less GitHub-native

### Self-Hosted Runners
**✅ Pros:**
- Native GitHub Actions
- Better security model
- Rich GitHub UI integration
- Standard approach

**❌ Cons:**
- Token management complexity
- Manual registration per machine
- Tokens expire periodically
- More moving parts

## Recommendation

**Stick with the webhook system** for your use case because:

1. **Personal scale**: Perfect for a few machines
2. **Zero maintenance**: No token renewals or registrations
3. **Plug-and-play**: New machines work immediately after install
4. **Offline resilience**: Handles disconnected machines gracefully

The webhook approach gives you all the benefits without the operational overhead of managing runner tokens across multiple personal machines.
