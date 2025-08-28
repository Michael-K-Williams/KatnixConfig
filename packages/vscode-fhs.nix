{ pkgs, lib, ... }:

pkgs.buildFHSEnv {
  name = "code";
  
  targetPkgs = pkgs: with pkgs; [
    # Core system libraries
    stdenv.cc.cc.lib
    zlib
    openssl
    curl
    expat
    libxml2
    libxslt
    
    # Graphics and display
    fontconfig
    freetype
    libxkbcommon
    libGL
    mesa
    libgbm
    vulkan-loader
    libdrm
    
    # X11/Xorg libraries
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    
    # GTK/GUI libraries
    systemd
    glib
    gtk3
    pango
    cairo
    gdk-pixbuf
    atk
    
    # Audio and system services
    nss
    nspr
    alsa-lib
    at-spi2-core
    cups
    dbus
    polkit
    
    # Development tools
    nodejs
    python3
    gcc
    gnumake
    
    # Fonts for VSCode
    google-fonts
    source-code-pro
    jetbrains-mono
    ubuntu_font_family
    dejavu_fonts
    liberation_ttf
    cascadia-code
    ibm-plex
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    powerline-fonts
    material-design-icons
    
    # Nerd Fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.meslo-lg
    nerd-fonts.droid-sans-mono
  ];
  
  runScript = "/opt/vscode-mutable/bin/code";
}