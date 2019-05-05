{ lib
, haskellLib
, nixpkgs
, omitInterfacePragmas
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

    combined-any
    (optionalExtension (!(super.ghc.isGhcjs or false)) combined-ghc)

    user-custom
  ] self super;

  combined-any = self: super: foldExtensions [
    any
    (optionalExtension (versionWildcard [ 8 ] (getGhcVersion super.ghc)) combined-any-8)
  ] self super;

  combined-any-8 = self: super: foldExtensions [
    any-8
    (optionalExtension (versionWildcard [ 8 4 ] (getGhcVersion super.ghc)) any-8_4)
    (optionalExtension (versionWildcard [ 8 6 ] (getGhcVersion super.ghc)) any-8_6)
    (optionalExtension (lib.versionOlder "8.7"  (getGhcVersion super.ghc)) any-head)
  ] self super;

  combined-ghc = self: super: foldExtensions [
    (optionalExtension (versionWildcard [ 8 4 ] super.ghc.version) ghc-8_4)
    (optionalExtension (versionWildcard [ 8 6 ] super.ghc.version) ghc-8_6)
    (optionalExtension (lib.versionOlder "8.7"  super.ghc.version) ghc-head)
  ] self super;

  ##
  ## Constituents
  ##

  lunaPackages = import ./luna-packages {
    inherit haskellLib lib nixpkgs omitInterfacePragmas;
  };

  any = _ : _ : {};
  any-8 = import ./any-8.nix { inherit lib haskellLib; inherit (nixpkgs) pkgs; };
  any-8_4 = _ : _ : {};
  any-8_6 = _ : _ : {};
  any-head = _ : _ : {};

  ghc-8_4 = _: _: {};
  ghc-8_6 = _: _: {};
  ghc-head = _: _: {};

  user-custom = foldExtensions haskellOverlays;
}
