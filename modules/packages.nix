{ config, pkgs, inputs, ... }:
{
  # Font configuration
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Nerd Fonts (patched fonts with icons)
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.ubuntu-mono
      nerd-fonts.dejavu-sans-mono
      cascadia-code
      nerd-fonts.meslo-lg
      nerd-fonts.droid-sans-mono
      
      # Google Fonts (includes Noto Sans Mono)
      google-fonts
      
      # Additional monospace fonts
      source-code-pro
      jetbrains-mono
      ubuntu_font_family
      dejavu_fonts
      liberation_ttf
      cascadia-code
      ibm-plex
      
      # Icon and symbol fonts
      font-awesome
      powerline-fonts
      material-design-icons
      
      # Ensure good Unicode coverage
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrains Mono" "Fira Code" "Source Code Pro" "DejaVu Sans Mono" ];
      };
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Core system tools
    vim 
    wget
    curl
    git
    gh
    unzip
    htop
    
    # Terminal and shell
    alacritty
    zsh
    fastfetch
    bat
    lsd
    tree
    
    # Desktop applications
    firefox
    claude-code
    vesktop
    spotify
    steam
    libreoffice
    thunderbird
    
    # KDE packages
    kdePackages.sddm-kcm
    kdePackages.kcalc
    kdePackages.konversation
    kdePackages.ghostwriter
    kdePackages.kate
    kdePackages.dolphin
    kdePackages.spectacle
    kdePackages.okular
    kdePackages.partitionmanager
    
    # Development tools
    # VSCode provided by vscode-mutable module (FHS environment + mutable installation)
    
    # System utilities
    polkit
    networkmanagerapplet
    
    # Gaming
    lutris
    wine
    winetricks
    
    # Media
    vlc
    gimp
    
    # Virtualization
    virtualbox
    
    # Katnix command tool
    katnix
    
    # Proton GE installer script
    install-proton-ge-10-12
    
    # SDDM theme
    where-is-my-sddm-theme
  ];
  
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Enable VirtualBox
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
  users.extraGroups.vboxusers.members = [ "thealtkitkat" ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Auto-install Proton GE 10-12 on system activation
  system.activationScripts.install-proton-ge = {
    text = ''
      USER_HOME="/home/thealtkitkat"
      STEAM_DIR="$USER_HOME/.steam/steam/compatibilitytools.d"
      PROTON_DIR="$STEAM_DIR/GE-Proton10-12"
      
      if [ ! -d "$PROTON_DIR" ]; then
        echo "Installing Proton GE 10-12..."
        
        # Create temp directory
        TEMP_DIR="/tmp/proton-ge-10-12-install"
        rm -rf "$TEMP_DIR"
        mkdir -p "$TEMP_DIR"
        cd "$TEMP_DIR"
        
        # Download tarball
        ${pkgs.curl}/bin/curl -# -L "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-12/GE-Proton10-12.tar.gz" -o "GE-Proton10-12.tar.gz"
        
        # Verify checksum
        echo "47dffcff346b35c75649a95a012ad4e9b6376087dceb43ac7b695e04f5ed3c1e  GE-Proton10-12.tar.gz" | ${pkgs.coreutils}/bin/sha256sum -c
        
        # Create steam directory and extract
        mkdir -p "$STEAM_DIR"
        ${pkgs.gnutar}/bin/tar -xf "GE-Proton10-12.tar.gz" -C "$STEAM_DIR/"
        
        # Set ownership to user
        chown -R thealtkitkat:users "$STEAM_DIR/GE-Proton10-12"
        
        # Cleanup
        rm -rf "$TEMP_DIR"
        
        echo "Proton GE 10-12 installed successfully!"
      else
        echo "Proton GE 10-12 already installed."
      fi
    '';
    deps = [];
  };
}
