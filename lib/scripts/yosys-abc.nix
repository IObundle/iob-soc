# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib;
  cmake = pkgs.cmake;
  libedit = pkgs.libedit;
  rev = "896e5e7dedf9b9b1459fa019f1fa8aa8101fdf43";
  yosys_abc_src = pkgs.fetchFromGitHub {
    owner = "YosysHQ";
    repo = "abc";
    rev = rev;
    sha256 = "sha256-sMBCIV698TIvU/sgTwgPFWDC1kl2TeGv+3pQ06gs7aM=";
  };
  yosys_abc = pkgs.clangStdenv.mkDerivation rec {
    name = "yosys-abc";
    src = yosys_abc_src;
    patches = [
      ./patches/yosys/abc-editline.patch
    ];
    postPatch = ''
      sed -i "s@-lreadline@-ledit@" ./Makefile
    '';
    nativeBuildInputs = [ cmake ];
    buildInputs = [ libedit ];
    installPhase = "mkdir -p $out/bin && mv abc $out/bin";
    passthru.rev = rev;
    meta = with lib; {
      description = "A tool for squential logic synthesis and formal verification (YosysHQ's Fork)";
      homepage = "https://people.eecs.berkeley.edu/~alanmi/abc";
      license = licenses.mit;
      mainProgram = "abc";
      platforms = platforms.unix;
    };
  };
in
yosys_abc