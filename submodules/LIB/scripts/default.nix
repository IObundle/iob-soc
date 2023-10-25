{ pkgs ? import (builtins.fetchTarball {
  # Descriptive name to make the store path easier to identify
  name = "nixos-22.11";
  # Commit hash for nixos-22.11
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.11.tar.gz";
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
}) {}}:
pkgs.mkShell {
  name = "iob-shell";
  buildInputs = with pkgs; [     
    bash
    gnumake
    verilog
    verilator
    gtkwave
    python3
    python3Packages.black
    python3Packages.parse
    python3Packages.numpy
    python3Packages.wavedrom
    python3Packages.matplotlib
    python3Packages.scipy
    python3Packages.pyserial
    (texlive.combine { inherit (texlive) scheme-medium multirow lipsum catchfile nowidow enumitem placeins xltabular ltablex titlesec makecell datetime fmtcount ; })
    (callPackage ./riscv-gnu-toolchain.nix { })
    verible
    black
    llvmPackages_14.clangUseLLVM
    librsvg
    libreoffice
  ];
}
