{ pkgs ? import <nixpkgs> {} }:

{
  edmc = pkgs.callPackage ./edmc.nix {};
}