{ pkgs, lib, config, userName ? "thealtkitkat", ... }:

{
  # FHS environment for VSCode with all necessary libraries
  vscode-fhs = pkgs.buildFHSEnv {
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
      systemd
      glib
      gtk3
      pango
      cairo
      gdk-pixbuf
      atk
      
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
      
      # Audio and system services
      nss
      nspr
      alsa-lib
      at-spi2-core
      cups
      dbus
      libdrm
      mesa
      libgbm
      vulkan-loader
      libGL
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
      cascadia-code
      nerd-fonts.meslo-lg
      nerd-fonts.droid-sans-mono
    ];
    runScript = "/opt/vscode-mutable/bin/code";
  };

  # System activation script for mutable VSCode installation
  vscode-activation-script = ''
    ${pkgs.writeShellScript "install-vscode" ''
      set -e
      
      VSCODE_DIR="/opt/vscode-mutable"
      VSCODE_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
      
      # Create directory if it doesn't exist
      mkdir -p "$VSCODE_DIR"
      
      # Download and extract if not already present
      if [ ! -f "$VSCODE_DIR/bin/code" ]; then
        echo "Installing VS Code to $VSCODE_DIR..." >&2
        cd /tmp
        echo "Downloading from $VSCODE_URL..." >&2
        ${pkgs.wget}/bin/wget -O vscode.tar.gz "$VSCODE_URL" || {
          echo "Download failed, trying alternative URL..." >&2
          ${pkgs.wget}/bin/wget -O vscode.tar.gz "https://az764295.vo.msecnd.net/stable/384ff7382de624fb94dbaf6da11977bba1ecd427/code-stable-x64-1733244016.tar.gz"
        }
        echo "Extracting VS Code..." >&2
        PATH="${pkgs.gzip}/bin:$PATH" ${pkgs.gnutar}/bin/tar -xzf vscode.tar.gz -C "$VSCODE_DIR" --strip-components=1
        chown -R ${userName}:users "$VSCODE_DIR"
        chmod -R 755 "$VSCODE_DIR"
        rm -f vscode.tar.gz
        echo "VS Code installation completed" >&2
      fi
      
      # Create desktop entry in user directory
      mkdir -p /home/${userName}/.local/share/applications
      cat > /home/${userName}/.local/share/applications/code.desktop << EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=code %F
Icon=/opt/vscode-mutable/resources/app/resources/linux/code.png
Type=Application
StartupNotify=true
StartupWMClass=Code
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=code --new-window %F
Icon=/opt/vscode-mutable/resources/app/resources/linux/code.png
EOF
      
      # Set proper ownership for desktop entry
      chown ${userName}:users /home/${userName}/.local/share/applications/code.desktop
      
      # Update desktop database
      ${pkgs.desktop-file-utils}/bin/update-desktop-database /home/${userName}/.local/share/applications || true
      
      echo "VS Code downloaded and extracted successfully" >&2
      
      echo "VS Code installed to $VSCODE_DIR and available as 'code'" >&2
    ''}
  '';
}