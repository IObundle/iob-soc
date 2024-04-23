{ pkgs ? import <nixpkgs> {} }:

let
  yosys_abc = import ./yosys-abc.nix { inherit pkgs; };

  symlinkJoin = pkgs.symlinkJoin;
  python3 = pkgs.python3;
  lib = pkgs.lib;
  makeWrapper = pkgs.makeWrapper;
  clangStdenv = pkgs.clangStdenv;
  fetchFromGitHub = pkgs.fetchFromGitHub;
  pkg-config = pkgs.pkg-config;
  bison = pkgs.bison;
  flex = pkgs.flex;
  tcl = pkgs.tcl;
  libedit = pkgs.libedit;
  libbsd = pkgs.libbsd;
  libffi = pkgs.libffi;
  zlib = pkgs.zlib;

  py3env = python3.withPackages (pp:
    with pp; [
      click
      xmlschema
    ]);
  
  yosys = clangStdenv.mkDerivation rec {
    name = "yosys";

    src = fetchFromGitHub {
      owner = "YosysHQ";
      repo = "yosys";
      rev = "543faed9c8cd7c33bbb407577d56e4b7444ba61c";
      sha256 = "sha256-mzMBhnIEgToez6mGFOvO7zBA+rNivZ9OnLQsjBBDamA=";
    };

    nativeBuildInputs = [pkg-config bison flex];
    propagatedBuildInputs = [yosys_abc];

    buildInputs = [
      tcl
      libedit
      libbsd
      libffi
      zlib
      py3env
    ];

    passthru = {
      inherit py3env;
      inherit withPlugins;
    };

    patches = [
      ./patches/yosys/fix-clang-build.patch
      ./patches/yosys/plugin-search-dirs.patch
    ];

    postPatch = ''
      substituteInPlace ./Makefile \
        --replace 'echo UNKNOWN' 'echo ${builtins.substring 0 10 src.rev}'

      chmod +x ./misc/yosys-config.in
      patchShebangs tests ./misc/yosys-config.in

      sed -i 's@ENABLE_EDITLINE := 0@ENABLE_EDITLINE := 1@' Makefile
      sed -i 's@ENABLE_READLINE := 1@ENABLE_READLINE := 0@' Makefile
      sed -Ei 's@PRETTY = 1@PRETTY = 0@' ./Makefile
    '';

    preBuild = let
      shortAbcRev = builtins.substring 0 7 yosys_abc.rev;
    in ''
      chmod -R u+w .
      make config-clang

      echo 'ABCEXTERNAL = ${yosys_abc}/bin/abc' >> Makefile.conf

      if ! grep -q "ABCREV = ${shortAbcRev}" Makefile; then
        echo "ERROR: yosys isn't compatible with the provided abc (${yosys_abc}), failing."
        exit 1
      fi
    '';

    postBuild = "ln -sfv ${yosys_abc}/bin/abc ./yosys-abc";
    postInstall = "ln -sfv ${yosys_abc}/bin/abc $out/bin/yosys-abc";

    makeFlags = ["PREFIX=${placeholder "out"}"];
    doCheck = false;
    enableParallelBuilding = true;
  };

  withPlugins = plugins: let
    paths = lib.closePropagation plugins;
    dylibs = lib.lists.flatten (map (n: n.dylibs) plugins);
  in let
    module_flags = with builtins;
      concatStringsSep " "
      (map (so: "--add-flags -m --add-flags ${so}") dylibs);
  in (symlinkJoin {
    name = "${yosys.name}-with-plugins";
    paths = paths ++ [yosys];
    nativeBuildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/yosys \
        --set NIX_YOSYS_PLUGIN_DIRS $out/share/yosys/plugins \
        ${module_flags}
    '';
  });
in
  yosys
