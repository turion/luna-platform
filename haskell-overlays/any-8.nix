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

  # luna will not work with megaparsec >= 7 yet
  megaparsec = super.megaparsec_6_5_0;
  hspec-megaparsec = overrideCabal super.hspec-megaparsec (drv: {
    version = "1.1.0";
    sha256 = "1929fnpys1j7nja1c3limyl6f259gky9dpf98xyyx0pi663qdmf1";
    editedCabalFile = null;
  });
  neat-interpolation = overrideCabal super.neat-interpolation (drv: {
    version = "0.3.2.2";
    sha256 = "0ffcr6q9bmvlmz5j8s0q08pbqzcfz9pkh8gz52arzscflpncbj5n";
    editedCabalFile = null;
  });

  system-fileio = doJailbreak super.system-fileio;

  zeromq4-haskell = dontCheck (overrideCabal super.zeromq4-haskell (drv: {
    broken = false;
  }));

  # luna-empire wants == 0.6.1.2
  zlib = overrideCabal super.zlib (drv: {
    version = "0.6.1.2";
    sha256 = "1fx2k2qmgm2dj3fkxx2ry945fpdn02d4dkihjxma21xgdiilxsz4";
    editedCabalFile = null;
  });
}
