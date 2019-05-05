{ lib
, haskellLib
, nixpkgs
, haskellOverlays
}:

rec {
  foldExtensions = lib.foldr lib.composeExtensions (_: _: {});

  optionalExtension = cond: overlay: if cond then overlay else _: _: {};

  versionWildcard = versionList: let
    versionListInc = lib.init versionList ++ [ (lib.last versionList + 1) ];
    bottom = lib.concatStringsSep "." (map toString versionList);
    top = lib.concatStringsSep "." (map toString versionListInc);
  in version: lib.versionOlder version top && lib.versionAtLeast version bottom;

  getGhcVersion = ghc:
    if ghc.isGhcjs or false
    then ghc.ghcVersion
    else ghc.version;

  ##
  ## Conventional roll ups of all the constituent overlays below
  ##

  combined = self: super: foldExtensions [
    lunaPackages

    combined-ghc

    user-custom
  ] self super;

  combined-ghc = self: super: foldExtensions [
    (optionalExtension (versionWildcard [ 8 4 ] super.ghc.version) ghc-8_4)
    (optionalExtension (lib.versionOlder "8.5"  super.ghc.version) ghc-head)
  ] self super;

  ##
  ## Constituents
  ##

  lunaPackages = import ./luna-packages {
    inherit haskellLib lib nixpkgs;
  };

  ghc-8_4 = import ./ghc-8_4.nix { inherit lib haskellLib; inherit (nixpkgs) pkgs; };
  ghc-head = _: _: {};

  user-custom = foldExtensions haskellOverlays;
}
