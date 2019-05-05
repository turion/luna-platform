{ pkgs, lib, haskellLib }:

with haskellLib;

self: super: {
  category = overrideCabal super.category (drv: {
    postPatch = ''
      sed -i -e 's/build-type:.*/build-type: Custom/' category.cabal
      cat >> category.cabal <<EOF
      custom-setup
        setup-depends: alg
      EOF
    '';
    setupHaskellDepends = with pkgs.haskellPackages; [ alg base Cabal transformers ];
  });
}
