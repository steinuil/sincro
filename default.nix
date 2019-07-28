{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  version = "0.1.0";

  name = "sincro-${version}";

  buildInputs = [ go ];
}
