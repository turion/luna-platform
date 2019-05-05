{ nixpkgsFunc ? import ./nixpkgs

# build options
, omitInterfacePragmas ? true # TODO: should be false by default

# custom overlays to include
, nixpkgsOverlays ? []
, haskellOverlays ? []
}:

let
  bindHaskellOverlays = self: super: {
    haskell = super.haskell // {
      overlays = super.overlays or {} // import ./haskell-overlays {
        nixpkgs = self;
        inherit (self) lib;
        haskellLib = self.haskell.lib;
        inherit omitInterfacePragmas
                haskellOverlays;
      };
    };
  };

  nixpkgsArgs = {
    overlays = [
      bindHaskellOverlays
    ] ++ nixpkgsOverlays;
  };

  nixpkgs = nixpkgsFunc nixpkgsArgs;

  inherit (nixpkgs) lib;

  haskellLib = nixpkgs.haskell.lib;

  combineOverrides = old: new: old // new // lib.optionalAttrs (old ? overrides && new ? overrides) {
    overrides = lib.composeExtensions old.overrides new.overrides;
  };

  # Makes sure that old `overrides` from a previous call to `override` are not
  # forgotten, but composed. Do this by overriding `override` and passing a
  # function which takes the old argument set and combining it. What a tongue
  # twister!
  makeRecursivelyOverridable = x: x // {
    override = new: makeRecursivelyOverridable (x.override (old: (combineOverrides old new)));
  };

  ghc = ghc8_4;
  ghc8_4 = (makeRecursivelyOverridable nixpkgs.haskell.packages.ghc844).override {
    overrides = nixpkgs.haskell.overlays.combined;
  };
  ghc8_6 = (makeRecursivelyOverridable nixpkgs.haskell.packages.ghc864).override {
    overrides = nixpkgs.haskell.overlays.combined;
  };
in let this = rec {
  inherit nixpkgs
          ghc
          ghc8_4
          ghc8_6
          ;
}; in this
