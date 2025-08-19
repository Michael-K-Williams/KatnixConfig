{ config, pkgs, ... }:
let
  xenlism-grub-theme = pkgs.stdenv.mkDerivation rec {
    pname = "xenlism-grub-theme";
    version = "1.0";
    
    src = pkgs.fetchzip {
      url = "https://github.com/xenlism/Grub-themes/archive/096b311f88ba10960f89d42dffa5b4229e752ca2.zip";
      sha256 = "sha256-kHDYGNM4z8V/JYtBXgAMuf1l/6JSi6YgguSuiuSp2ZY=";
    };
    
    installPhase = ''
      mkdir -p $out
      cp -r xenlism-grub-1080p-nixos/* $out/
    '';
    
    meta = with pkgs.lib; {
      description = "Xenlism Grub Theme for NixOS (1080p)";
      homepage = "https://github.com/xenlism/Grub-themes";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };
in
{
  # Bootloader configuration
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      theme = xenlism-grub-theme;
    };
    efi.canTouchEfiVariables = true;
  };
}
