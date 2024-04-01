{ pkgs ? import <nixpkgs> {} }:

let
  rev = "bfd938b5e2321cf9a6c15f398fbc987b56fcc179";
  magicSrc = pkgs.fetchFromGitHub {
    owner = "RTimothyEdwards";
    repo = "magic";
    rev = rev;
    sha256 = "sha256-xNhPnNGoJ8YiG6NFeFhOuKTB56rQvggJugIvukao6U8=";
  };
  magic = pkgs.stdenv.mkDerivation {
    name = "magic-vlsi";
    src = magicSrc;
    nativeBuildInputs = [ pkgs.python3 pkgs.gnused ];
    buildInputs = [
      pkgs.xorg.libX11
      pkgs.m4
      pkgs.ncurses
      pkgs.tcl
      pkgs.tcsh
      pkgs.tk
      pkgs.cairo
      pkgs.mesa_glu      # Add GLU development files
    ];
    configureFlags = [
      "--with-tcl=${pkgs.tcl}"
      "--with-tk=${pkgs.tk}"
      "--disable-werror"
    ];
    NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration -Wno-parentheses -Wno-macro-redefined";
    postPatch = ''
      sed -i "s/dbReadOpen(cellDef, name,/dbReadOpen(cellDef, name != NULL,/" database/DBio.c
    '';
    preConfigure = ''
      patchShebangs ./scripts
      sed -i 's@`git rev-parse HEAD`@${rev}@' ./scripts/defs.mak.in
    '';
    fixupPhase = ''
      sed -i "13iexport CAD_ROOT='$out/lib'" $out/bin/magic
      patchShebangs $out/bin/magic
    '';
    meta = with pkgs.lib; {
      description = "VLSI layout tool written in Tcl";
      homepage = "http://opencircuitdesign.com/magic/";
      license = licenses.mit;
      platforms = platforms.linux ++ platforms.darwin;
    };
  };
in

magic