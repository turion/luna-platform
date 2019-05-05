{ pkgs, lib, haskellLib }:

with haskellLib;

self: super: {
  # fails to build with "Could not find module Algebra"
  # https://github.com/NixOS/nixpkgs/issues/44565
  category = overrideCabal super.category (drv: {
    broken = false;
    setupHaskellDepends = [ super.alg ];
  });

  constraint = overrideCabal super.constraint (drv: {
    broken = false;
  });

  # broken tests
  Diff = dontCheck super.Diff;
}
