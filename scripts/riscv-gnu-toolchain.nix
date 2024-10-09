# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "riscv-gnu-toolchain";
  src = pkgs.fetchFromGitHub {
    repo = "riscv-gnu-toolchain";
    owner = "riscv-collab";
    rev = "2022.06.10";
    fetchSubmodules = true;
    #leaveDotGit = true; #This is not deterministic, causes issues with hash. https://github.com/NixOS/nixpkgs/issues/8567
    sha256 = "sha256-KjbVnUfvk7JEWsFPz7x7HZolAJ/PvQaBEwAoF/G0lQw=";
  };
  buildInputs = [ 
     pkgs.gmp
     pkgs.libmpc
     pkgs.mpfr
   ];
  nativeBuildInputs = [
     pkgs.gcc
     pkgs.python3
     pkgs.util-linux
     pkgs.git
     pkgs.cacert
     pkgs.autoconf
     pkgs.automake
     pkgs.curl
     pkgs.python3
     pkgs.gawk
     pkgs.bison
     pkgs.flex
     pkgs.texinfo
     pkgs.gperf
     pkgs.bc
     pkgs.perl
     pkgs.expat
  ];
  buildPhase = ''
    # Build in /tmp dir because the Nix tmpfs build/ partition does not have enough space to build this toolchain
    rm -fr /tmp/`basename $src`
    cp -r $src /tmp/`basename $src`
    cd /tmp/`basename $src`
    chmod +w -R .
    # Hack to manually create git reposiories because .git folders were deleted by leaveDotGit=false
    for path in "." "riscv-gcc" "riscv-gdb" "riscv-binutils" "newlib"; do
        env -C $path git init --initial-branch=main;
    done
    ./configure --prefix=$out --enable-multilib
    make -j$(nproc)
  '';
  installPhase = ''
    cd /tmp/`basename $src`
    make install
  '';

  clean = ''
    rm -fr /tmp/`basename $src`
  '';

  hardeningDisable = [ "format" ];
}
