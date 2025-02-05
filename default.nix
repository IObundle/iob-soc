# SPDX-FileCopyrightText: 2025 IObundle
#
# SPDX-License-Identifier: MIT

{ pkgs ? import <nixpkgs> {} }:

let
  py2hwsw_commit = "9ffc5f3acf9e7f0753548b45b2ce06b108de2e78"; # Replace with the desired commit.
  py2hwsw_sha256 = "U4ux/H2b3s/RZnhTEcaROpPLuhDnamlwHiqOV7cgfYc="; # Replace with the actual SHA256 hash.
  # Get local py2hwsw root from `PY2HWSW_ROOT` env variable
  py2hwswRoot = builtins.getEnv "PY2HWSW_ROOT";

  # For debug
  force_py2_build = 0;

  py2hwsw = 
    # If no root is provided, or there is a root but we want to force a rebuild
    if py2hwswRoot == "" || force_py2_build != 0 then
      pkgs.python3.pkgs.buildPythonPackage rec {
        pname = "py2hwsw";
        version = py2hwsw_commit;
        src =
          if py2hwswRoot != "" then
            # Root provided, use local
            pkgs.lib.cleanSource py2hwswRoot
          else
            # No root provided, use GitHub
            (pkgs.fetchFromGitHub {
              owner = "IObundle";
              repo = "py2hwsw";
              rev = py2hwsw_commit;
              sha256 = py2hwsw_sha256;
              fetchSubmodules = true;
            }).overrideAttrs (_: {
              GIT_CONFIG_COUNT = 1;
              GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
              GIT_CONFIG_VALUE_0 = "git@github.com:";
            });
        # Add any necessary dependencies here.
        #propagatedBuildInputs = [ pkgs.python38Packages.someDependency ];
      }
    else
      null;


in

# If no root is provided, or there is a root but we want to force a rebuild
if py2hwswRoot == "" || force_py2_build != 0 then
  # Use newly built nix package
  import "${py2hwsw}/lib/python${builtins.substring 0 4 pkgs.python3.version}/site-packages/py2hwsw/lib/default.nix" { inherit pkgs; py2hwsw_pkg = py2hwsw; }
else
  # Use local
  import "${py2hwswRoot}/py2hwsw/lib/default.nix" { inherit pkgs; py2hwsw_pkg = py2hwsw; }
