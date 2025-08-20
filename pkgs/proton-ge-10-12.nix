{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "GE-Proton10-12";
  version = "10-12";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-12/GE-Proton10-12.tar.gz";
    sha256 = "47dffcff346b35c75649a95a012ad4e9b6376087dceb43ac7b695e04f5ed3c1e";
  };

  installPhase = ''
    mkdir -p $out
    tar -xzf $src -C $out --strip-components=1
  '';

  meta = {
    description = "Proton GE Custom 10-12";
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    platforms = [ "x86_64-linux" ];
  };
}