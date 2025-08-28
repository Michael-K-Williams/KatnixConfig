{ pkgs, lib, ... }:

pkgs.writeShellScriptBin "vscode-mutable-installer" ''
  set -e
  
  VSCODE_DIR="''${VSCODE_DIR:-/opt/vscode-mutable}"
  VSCODE_URL="''${VSCODE_URL:-https://code.visualstudio.com/sha/download?build=stable&os=linux-x64}"
  FALLBACK_URL="''${FALLBACK_URL:-https://az764295.vo.msecnd.net/stable/384ff7382de624fb94dbaf6da11977bba1ecd427/code-stable-x64-1733244016.tar.gz}"
  USER_NAME="''${USER_NAME:-$(whoami)}"
  
  # Create directory if it doesn't exist
  if [[ $EUID -eq 0 ]]; then
    mkdir -p "$VSCODE_DIR"
  else
    sudo mkdir -p "$VSCODE_DIR"
  fi
  
  # Download and extract if not already present
  if [ ! -f "$VSCODE_DIR/bin/code" ]; then
    echo "Installing VS Code to $VSCODE_DIR..."
    cd /tmp
    echo "Downloading from $VSCODE_URL..."
    if ! ${pkgs.wget}/bin/wget -O vscode.tar.gz "$VSCODE_URL"; then
      echo "Download failed, trying fallback URL..."
      ${pkgs.wget}/bin/wget -O vscode.tar.gz "$FALLBACK_URL"
    fi
    echo "Extracting VS Code..."
    if [[ $EUID -eq 0 ]]; then
      PATH="${pkgs.gzip}/bin:$PATH" ${pkgs.gnutar}/bin/tar -xzf vscode.tar.gz -C "$VSCODE_DIR" --strip-components=1
      chown -R $USER_NAME:users "$VSCODE_DIR"
      chmod -R 755 "$VSCODE_DIR"
    else
      PATH="${pkgs.gzip}/bin:$PATH" sudo ${pkgs.gnutar}/bin/tar -xzf vscode.tar.gz -C "$VSCODE_DIR" --strip-components=1
      sudo chown -R $USER_NAME:users "$VSCODE_DIR"
      sudo chmod -R 755 "$VSCODE_DIR"
    fi
    rm -f vscode.tar.gz
    echo "VS Code installation completed"
  fi
  
  # Create symlink in /usr/local/bin if it doesn't exist
  if [[ $EUID -eq 0 ]]; then
    mkdir -p /usr/local/bin
    ln -sf "$VSCODE_DIR/bin/code" /usr/local/bin/code
  else
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$VSCODE_DIR/bin/code" /usr/local/bin/code
  fi
  
  # Create desktop entry in user directory
  DESKTOP_DIR="/home/$USER_NAME/.local/share/applications"
  if [[ $EUID -eq 0 ]]; then
    mkdir -p "$DESKTOP_DIR"
  else
    mkdir -p "$DESKTOP_DIR"
  fi
  
  cat > "$DESKTOP_DIR/code.desktop" << EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=code %F
Icon=$VSCODE_DIR/resources/app/resources/linux/code.png
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
Icon=$VSCODE_DIR/resources/app/resources/linux/code.png
EOF
  
  # Set proper ownership for desktop entry
  if [[ $EUID -eq 0 ]]; then
    chown $USER_NAME:users "$DESKTOP_DIR/code.desktop"
  fi
  
  # Update desktop database
  if command -v update-desktop-database >/dev/null 2>&1; then
    ${pkgs.desktop-file-utils}/bin/update-desktop-database "$DESKTOP_DIR" || true
  fi
  
  echo "VS Code installed to $VSCODE_DIR and available as 'code'"
  echo "Desktop entry created at $DESKTOP_DIR/code.desktop"
''
