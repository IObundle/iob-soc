{ pkgs ? import <nixpkgs> {} }:

let
  py2hwsw_commit = "b172a172cf8bca1def15cb5b6c4fb1f2d4dfd17e"; # Replace with the desired commit.

  py2hwsw = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "py2hwsw";
    version = py2hwsw_commit;

    src = pkgs.fetchFromGitHub {
      owner = "IObundle";
      repo = "py2hwsw";
      rev = py2hwsw_commit;
      sha256 = "Ql8v4fhhoE3PeZk1I99+UVnrE7P0FjUD5sQvp01aI84=";  # Replace with the actual SHA256 hash.
    };

    # Add any necessary dependencies here.
    #propagatedBuildInputs = [ pkgs.python38Packages.someDependency ];
  };

  yosys = import ./yosys.nix { inherit pkgs; };
in

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
    python3Packages.mypy
    python3Packages.parse
    python3Packages.numpy
    python3Packages.wavedrom
    python3Packages.matplotlib
    python3Packages.scipy
    python3Packages.pyserial
    (texlive.combine { inherit (texlive) scheme-medium multirow lipsum catchfile nowidow enumitem placeins xltabular ltablex titlesec makecell datetime fmtcount comment textpos csquotes amsmath cancel listings hyperref biblatex; })
    (callPackage ./riscv-gnu-toolchain.nix { })
    verible
    black
    llvmPackages_14.clangUseLLVM
    librsvg
    libreoffice
    minicom     # Terminal emulator
    lrzsz       # For Zmodem file transfers via serial connection of the terminal emulator
    # Add Volare custom Python installation
    (let
      volareSrc = pkgs.fetchFromGitHub {
        owner = "efabless";
        repo = "volare";
        rev = "47325949b87e857d75f81d306f02ebccf952cb15";
        sha256 = "sha256-H9B/vZUs0O2jwmidCTMYhO0JY4DL+gmQNeVawaccvuU=";
      };
    in import "${volareSrc}" {
      inherit pkgs;
    })
    yosys
    py2hwsw
  ];
}
