{ pkgs ? import <nixpkgs> {} }:
import submodules/LIB/scripts/default.nix { inherit pkgs; }
