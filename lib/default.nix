{ pkgs ? import <nixpkgs> {} }:
import scripts/default.nix { inherit pkgs; }
