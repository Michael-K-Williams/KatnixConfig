{ lib, stdenv, python311, fetchurl, makeWrapper, wrapGAppsHook, gobject-introspection, gtk3, ... }:

stdenv.mkDerivation rec {
  pname = "edmarketconnector";
  version = "5.13.1";

  src = fetchurl {
    url = "https://github.com/EDCD/EDMarketConnector/releases/download/Release%2F${version}/EDMarketConnector-release-${version}.tar.gz";
    sha256 = "085698a6cde2594b7ec6a4888b8405fc65546a66347c6413dfddfd84ad8ac1ce";
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook
    gobject-introspection
  ];

  buildInputs = [
    gtk3
  ];

  pythonEnv = python311.withPackages (ps: with ps; [
    requests
    pillow
    watchdog
    semantic-version
    psutil
    tkinter
  ]);

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/edmarketconnector
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps

    cp -r . $out/share/edmarketconnector/

    makeWrapper ${pythonEnv}/bin/python $out/bin/edmarketconnector \
      --add-flags "$out/share/edmarketconnector/EDMarketConnector.py"

    cat > $out/share/applications/edmarketconnector.desktop << EOF
[Desktop Entry]
Name=ED Market Connector
Comment=Elite Dangerous Market Connector
Exec=$out/bin/edmarketconnector
Icon=applications-games
Terminal=false
Type=Application
Categories=Game;Utility;
StartupNotify=true
EOF

    # Copy icon if available, otherwise use system icon
    for icon_file in EDMarketConnector.png edmc.png icons/edmc.png *.ico; do
      if [ -f "$icon_file" ]; then
        cp "$icon_file" $out/share/pixmaps/edmarketconnector.png
        break
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Elite Dangerous Market Connector - trading and exploration data";
    longDescription = ''
      A companion app for Elite Dangerous that uploads trade and exploration 
      data to various online databases and provides market information.
    '';
    homepage = "https://github.com/EDCD/EDMarketConnector";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "edmarketconnector";
  };
}