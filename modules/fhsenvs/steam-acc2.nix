{ pkgs, ... }:

let
  # Use the nixpkg from the EDHM-Nix repository
  edhm-ui = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "Michael-K-Williams";
    repo = "EDHM-Nix";
    rev = "26958896ee41ab9b87e4d5ebfd32520480de069b";
    sha256 = "sha256-eI6/AmYHMHSu+0cVWxGnx/ua9Zq/7s7vdSsFsVzeBzo="; # Will be updated when first built
  }) {};
in
{
  environment.systemPackages = with pkgs; [
    # Steam Account 2 FHS Environment  
    (pkgs.buildFHSEnv {
      name = "steam-acc2";
      targetPkgs = pkgs: with pkgs; [
        steam
        steam-run
        firefox
        edmarketconnector
        ed-odyssey-materials-helper
        edhm-ui
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
        export HOME="$HOME/steam-acc2"
        mkdir -p "$HOME"
      '';
    })
  ];

  # Desktop entries for steam-acc2 FHS environment
  system.userActivationScripts.steam-acc2-desktop-entries = ''
    mkdir -p ~/.local/share/applications
    
    cat > ~/.local/share/applications/steam-acc2.desktop << 'EOF'
[Desktop Entry]
Name=Steam Account 2
Comment=Steam in isolated FHS environment
Exec=steam-acc2 -c "steam"
Icon=steam
Terminal=false
Type=Application
Categories=Game;
EOF

    cat > ~/.local/share/applications/firefox-acc2.desktop << 'EOF'
[Desktop Entry]
Name=Firefox Account 2
Comment=Firefox in isolated FHS environment
Exec=steam-acc2 -c "firefox"
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF

    cat > ~/.local/share/applications/edmc-acc2.desktop << 'EOF'
[Desktop Entry]
Name=EDMarketConnector Account 2
Comment=EDMarketConnector in FHS environment 2
Exec=steam-acc2 -c "edmarketconnector"
Icon=edmc
Terminal=false
Type=Application
Categories=Game;Utility;
EOF

    cat > ~/.local/share/applications/edmh-acc2.desktop << 'EOF'
[Desktop Entry]
Name=ED Materials Helper Account 2
Comment=ED Odyssey Materials Helper in FHS environment 2
Exec=steam-acc2 -c "ed-odyssey-materials-helper"
Icon=edmc
Terminal=false
Type=Application
Categories=Game;Utility;
EOF

    cat > ~/.local/share/applications/edhm-ui-acc2.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=EDHM UI Account 2
Comment=Elite Dangerous HUD Mod UI in FHS environment 2
Exec=steam-acc2 -c "edhm-ui-v3"
Icon=steam
Terminal=false
Type=Application
Categories=Game;
EOF
  '';
}