{ pkgs, ... }:

let
  # Use the nixpkg from the EDHM-Nix repository
  edhm-ui = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "Michael-K-Williams";
    repo = "EDHM-Nix";
    rev = "26958896ee41ab9b87e4d5ebfd32520480de069b";
    sha256 = "sha256-eI6/AmYHMHSu+0cVWxGnx/ua9Zq/7s7vdSsFsVzeBzo=";
  }) {};
in
{
  environment.systemPackages = with pkgs; [
    # Steam Account 1 FHS Environment
    (pkgs.buildFHSEnv {
      name = "steam-acc1";
      targetPkgs = pkgs: with pkgs; [
        steam
        steam-run
        firefox
        edmarketconnector
        ed-odyssey-materials-helper
        edhm-ui
        wl-clipboard
        # Libraries needed for EDHM_UI
        glib
        gtk3
        cairo
        pango
        gdk-pixbuf
        atk
        at-spi2-atk
        at-spi2-core
        dbus
        fontconfig
        freetype
        libdrm
        libxkbcommon
        mesa
        wayland
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
        # Additional libraries for Electron-based apps
        nss
        nspr
        cups
        xorg.libXScrnSaver
        alsa-lib
        libudev0-shim
        systemd
        expat
        zlib
        openssl
        mesa
        libgbm
      ];
      runScript = "bash";
      profile = ''
        export STEAM_EXTRA_COMPAT_TOOLS_PATHS="$HOME/.steam/root/compatibilitytools.d"
        export HOME="$HOME/steam-acc1"
        export EDMC_SPANSH_ROUTER_XCLIP="/usr/bin/wl-copy"
        mkdir -p "$HOME"
        mkdir -p "$HOME/EDHM_UI/ODYSS"
        mkdir -p "$HOME/EDHM_UI/HORIZONS"
        chmod -R 755 "$HOME/EDHM_UI" 2>/dev/null || true
      '';
    })
  ];

  # Create desktop entries in user home directories
  system.activationScripts.steam-acc1-desktop-entries = ''
    for user_home in /home/*; do
      if [[ -d "$user_home" ]]; then
        user=$(basename "$user_home")
        desktop_dir="$user_home/.local/share/applications"
        
        # Create directory and set proper ownership
        mkdir -p "$desktop_dir"
        chown "$user:users" "$desktop_dir" 2>/dev/null || true
        chown "$user:users" "$user_home/.local" 2>/dev/null || true
        chown "$user:users" "$user_home/.local/share" 2>/dev/null || true
        
        # Steam Account 1
        cat > "$desktop_dir/steam-acc1.desktop" << 'EOF'
[Desktop Entry]
Name=Steam Account 1
Comment=Steam in isolated FHS environment
Exec=steam-acc1 -c "steam"
Icon=steam
Terminal=false
Type=Application
Categories=Game;
EOF
        chown "$user:users" "$desktop_dir/steam-acc1.desktop" 2>/dev/null || true
        
        # Firefox Account 1
        cat > "$desktop_dir/firefox-acc1.desktop" << 'EOF'
[Desktop Entry]
Name=Firefox Account 1
Comment=Firefox in isolated FHS environment
Exec=steam-acc1 -c "firefox"
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF
        chown "$user:users" "$desktop_dir/firefox-acc1.desktop" 2>/dev/null || true
        
        # EDMarketConnector Account 1
        cat > "$desktop_dir/edmc-acc1.desktop" << 'EOF'
[Desktop Entry]
Name=EDMarketConnector Account 1
Comment=EDMarketConnector in FHS environment 1
Exec=steam-acc1 -c "edmarketconnector"
Icon=edmc
Terminal=false
Type=Application
Categories=Game;Utility;
EOF
        chown "$user:users" "$desktop_dir/edmc-acc1.desktop" 2>/dev/null || true
        
        # ED Materials Helper Account 1
        cat > "$desktop_dir/edmh-acc1.desktop" << 'EOF'
[Desktop Entry]
Name=ED Materials Helper Account 1
Comment=ED Odyssey Materials Helper in FHS environment 1
Exec=steam-acc1 -c "ed-odyssey-materials-helper"
Icon=edmc
Terminal=false
Type=Application
Categories=Game;Utility;
EOF
        chown "$user:users" "$desktop_dir/edmh-acc1.desktop" 2>/dev/null || true
        
        # EDHM UI Account 1
        cat > "$desktop_dir/edhm-ui-acc1.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Name=EDHM UI Account 1
Comment=Elite Dangerous HUD Mod UI in FHS environment 1
Exec=steam-acc1 -c "edhm-ui"
Icon=steam
Terminal=false
Type=Application
Categories=Game;
EOF
        chown "$user:users" "$desktop_dir/edhm-ui-acc1.desktop" 2>/dev/null || true
      fi
    done
  '';
}