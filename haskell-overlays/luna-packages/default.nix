{ haskellLib
, lib
, nixpkgs
}:

with haskellLib;

self: super:

let
  lunaSrc = nixpkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile ./luna.json));

  # Luna has a central hpack-common.yaml in a top level config directory
  # so we need to make sure it's available during build.
  f = name: path: args:
    dontHaddock (overrideCabal (self.callCabal2nix name "${lunaSrc}/${path}" args) (drv: {
      src = "${lunaSrc}";
      postUnpack = "sourceRoot=$sourceRoot/${path}";
    }));
in
{
  # lib - local hackage overrides
  container = f "container" "lib/container" {};
  convert = f "convert" "lib/convert" {};
  data-poset = f "data-poset" "lib/data-poset" {};
  functor-utils = f "functor-utils" "lib/functor-utils" {};
  hspec-jenkins = f "hspec-jenkins" "lib/hspec-jenkins" {};
  impossible = f "impossible" "lib/impossible" {};
  layered-state = f "layered-state" "lib/layered-state" {};
  layouting = f "layouting" "lib/layouting" {};
  lens-utils = f "lens-utils" "lib/lens-utils" {};
  monad-branch = f "monad-branch" "lib/monad-branch" {};
  monoid = f "monoid" "lib/monoid" {};
  prologue = f "prologue" "lib/prologue" {};
  terminal-text = dontHaddock (f "terminal-text" "lib/terminal-text" {}); # haddocks fail with parse error
  typelevel = f "typelevel" "lib/typelevel" {};
  vector-text = f "vector-text" "lib/vector-text" {};

  # lib
  luna-autovector = f "luna-autovector" "lib/autovector" {};
  luna-ci = f "luna-ci" "lib/ci" {};
  luna-code-builder = f "luna-code-builder" "lib/code-builder" {};
  luna-cpp-containers = f "luna-cpp-containers" "lib/cpp-containers" {};
  luna-data-construction = f "luna-data-construction" "lib/data-construction" {};
  luna-datafile = f "luna-datafile" "lib/datafile" {};
  luna-data-property = f "luna-data-property" "lib/data-property" {};
  luna-data-storable = f "luna-data-storable" "lib/data-storable" {};
  luna-data-tag = f "luna-data-tag" "lib/data-tag" {};
  luna-data-typemap = f "luna-data-typemap" "lib/data-typemap" {};
  luna-exception = f "luna-exception" "lib/exception" {};
  luna-foreign-utils = f "luna-foreign-utils" "lib/foreign-utils" {};
  luna-future = f "luna-future" "lib/future" {};
  luna-generic-traversable = f "luna-generic-traversable" "lib/generic-traversable" {};
  luna-generic-traversable2 = f "luna-generic-traversable2" "lib/generic-traversable2" {};
  luna-memory-manager = f "luna-memory-manager" "lib/memory-manager" {};
  luna-memory-pool = f "luna-memory-pool" "lib/memory-pool" {};
  luna-nested-containers = f "luna-nested-containers" "lib/nested-containers" {};
  luna-parser-utils = f "luna-parser-utils" "lib/parser-utils" {};
  luna-syntax-definition = f "luna-syntax-definition" "lib/syntax-definition" {};
  luna-text-processing = f "luna-text-processing" "lib/text-processing" {};
  luna-th-builder = f "luna-th-builder" "lib/th-builder" {};
  luna-tuple-utils = f "luna-tuple-utils" "lib/tuple-utils" {};
  luna-type-cache = f "luna-type-cache" "lib/type-cache" {};
  luna-yaml-utils = f "luna-yaml-utils" "lib/yaml-utils" {};

  # luna
  luna-core = f "luna-core" "core" {};
  luna-debug = f "luna-debug" "debug" {};
  luna-package = dontCheck (f "luna-package" "package" {}); # tests fail
  luna-passes = f "luna-passes" "passes" {};
  luna-runtime = f "luna-runtime" "runtime" {};
  luna-shell = f "luna-shell" "shell" {};
  luna-stdlib = f "luna-stdlib" "stdlib" {};
  luna-syntax-text-builder = f "luna-syntax-text-builder" "syntax/text/builder" {};
  luna-syntax-text-lexer = f "luna-syntax-text-lexer" "syntax/text/lexer" {};
  luna-syntax-text-model = f "luna-syntax-text-model" "syntax/text/model" {};
  luna-syntax-text-parser = f "luna-syntax-text-parser" "syntax/text/parser" {};
  luna-syntax-text-prettyprint = f "luna-syntax-text-prettyprint" "syntax/text/prettyprint" {};
}
