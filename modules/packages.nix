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
    vim 
    wget
    git
    gh
    alacritty
    firefox
    zsh
    claude-code
    vesktop
    spotify
    fastfetch
    bat
    lsd
    kdePackages.sddm-kcm
    kdePackages.kcalc
    kdePackages.konversation
    kdePackages.ghostwriter
    polkit
    inputs.katnix-commands.packages.${pkgs.system}.default
  ];
}
