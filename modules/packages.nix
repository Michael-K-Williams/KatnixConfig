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
    kdePackages.kscreenlocker
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
    
    # Katnix command tool
    inputs.katnix-commands.packages.${pkgs.system}.default
  ];
  
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
