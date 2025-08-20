{ stdenv, fetchurl, writeShellScript, ... }:

stdenv.mkDerivation rec {
  pname = "proton-ge-custom";
  version = "GE-Proton10-12";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-12/GE-Proton10-12.tar.gz";
    sha256 = "47dffcff346b35c75649a95a012ad4e9b6376087dceb43ac7b695e04f5ed3c1e";
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    
    # Create the directory structure expected by Steam
    mkdir -p $out
    cp -r ./* $out/
    
    runHook postInstall
  '';

  meta = {
    description = "Proton GE Custom 10-12 - Wine-based compatibility tool for Steam";
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    platforms = [ "x86_64-linux" ];
  };
}