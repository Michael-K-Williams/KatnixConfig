{ pkgs, lib, ... }:

pkgs.writeShellScriptBin "vscode-mutable-installer" ''
  set -e
  
  VSCODE_DIR="/opt/vscode-mutable"
  VSCODE_VERSION="1.96.2"
  VSCODE_URL="https://update.code.visualstudio.com/$VSCODE_VERSION/linux-x64/stable"
  
  # Create directory if it doesn't exist
  sudo mkdir -p "$VSCODE_DIR"
  
  # Download and extract if not already present
  if [ ! -f "$VSCODE_DIR/bin/code" ]; then
    echo "Installing VS Code to $VSCODE_DIR..."
    cd /tmp
    ${pkgs.wget}/bin/wget -O vscode.tar.gz "$VSCODE_URL"
    sudo tar -xzf vscode.tar.gz -C "$VSCODE_DIR" --strip-components=1
    sudo chown -R root:wheel "$VSCODE_DIR"
    sudo chmod -R 755 "$VSCODE_DIR"
    rm vscode.tar.gz
  fi
  
  # Create symlink in /usr/local/bin
  sudo mkdir -p /usr/local/bin
  sudo ln -sf "$VSCODE_DIR/bin/code" /usr/local/bin/code
  
  echo "VS Code installed to $VSCODE_DIR and available as 'code'"
''