{ haskellLib
, lib
, nixpkgs
, omitInterfacePragmas
}:

with haskellLib;

self: super:

let
  inherit (nixpkgs.buildPackages) fetchgit fetchFromGitHub;

  # luna-shell needs .git for githash
  lunaSrc = fetchgit (
    builtins.fromJSON (builtins.readFile ./luna.json) // { leaveDotGit = true; }
  );

  lunaStudioSrc = fetchgit (
    builtins.fromJSON (builtins.readFile ./luna-studio.json) // { leaveDotGit = true; }
  );

  addTestDepend = drv: x: addTestDepends drv [x];
  addTestDepends = drv: xs: overrideCabal drv (drv: { testHaskellDepends = (drv.testHaskellDepends or []) ++ xs; });

  # Regular doJailbreak is run in postPatch at which point the .cabal file may not exist yet.
  doJailbreakHpack = drv: overrideCabal drv (old: {
    preConfigure = old.preConfigure + ''
      echo "Run jailbreak-cabal to lift version restrictions on build inputs."
      ${super.jailbreak-cabal}/bin/jailbreak-cabal ${old.pname}.cabal
    '';
  });

  # Luna keeps common ghc-options in a central stack.yaml
  # see https://github.com/luna/luna/blob/master/stack.yaml
  ghcOptions =
    [ "-O1"
      "-Wall"
      "-Wno-name-shadowing"
      "-fexcess-precision"
      "-fexpose-all-unfoldings"
      "-flate-dmd-anal"
      "-fmax-worker-args=1000"
      "-fsimpl-tick-factor=400"
      "-fspec-constr-keen"
      "-fspecialise-aggressively"
      "-fstatic-argument-transformation"
      "-funbox-strict-fields"
      "-threaded"
      "-fconstraint-solver-iterations=100"
    ] ++ (if omitInterfacePragmas then ["-fomit-interface-pragmas"] else []);

  appendGhcOptions = opts: drv:
    # TODO: why doesn't this work?
    #let opts = lib.strings.concatStringsSep " " fs;
    #in appendConfigureFlag drv ("--ghc-options='" + opts + "'");
    lib.foldl' (res: x: appendConfigureFlag res ("--ghc-option=" + x)) drv opts;

  # Luna has a central hpack-common.yaml in a top level config directory
  # so we need to make sure it's available during build.
  callLunaPackage = src: name: path:
    dontHaddock (
      appendGhcOptions ghcOptions (
        overrideCabal (self.callCabal2nix name "${src}/${path}" {}) (drv: {
          src = "${src}";
          postUnpack = "sourceRoot=$sourceRoot/${path}";
    })));

  f = callLunaPackage lunaSrc;
  g = callLunaPackage lunaStudioSrc;
  prologue = f "prologue" "lib/prologue";
  typelevel = f "typelevel" "lib/typelevel";
  monad-branch = f "monad-branch" "lib/monad-branch";
in
{
  ##
  ## luna
  ##

  # lib - local hackage overrides
  container = f "container" "lib/container";
  convert = f "convert" "lib/convert";
  data-poset = f "data-poset" "lib/data-poset";
  functor-utils = f "functor-utils" "lib/functor-utils";
  hspec-jenkins = f "hspec-jenkins" "lib/hspec-jenkins";
  impossible = f "impossible" "lib/impossible";
  layered-state = f "layered-state" "lib/layered-state";
  layouting = f "layouting" "lib/layouting";
  lens-utils = f "lens-utils" "lib/lens-utils";
  monad-branch = monad-branch;
  monoid = f "monoid" "lib/monoid";
  prologue = prologue;
  terminal-text = dontHaddock (f "terminal-text" "lib/terminal-text"); # haddocks fail with parse error
  typelevel = typelevel;
  vector-text = f "vector-text" "lib/vector-text";

  # Use git version directly, hackage outdated?
  dependent-state = dontHaddock (
      appendGhcOptions ghcOptions (
        overrideCabal (
          self.callCabal2nix
          "dependent-state"
          (nixpkgs.fetchgit {
            url = "https://github.com/luna/dependent-state/";
            rev = "f1be47f0dbc6029d2ffcc6f0eb92fc9eb78bc3b6";
            sha256 = "142nfldd1n4gyqac3cmgdnfa2pnylilrkg7rx8a4s6i5lacn1gpa";
          }
          )
          {}
          ) (drv: {
            libraryHaskellDepends = [
              prologue
              typelevel
              monad-branch
              ];
          })
        ));

  # lib
  luna-autovector = f "luna-autovector" "lib/autovector";
  luna-ci = f "luna-ci" "lib/ci";
  luna-code-builder = f "luna-code-builder" "lib/code-builder";
  luna-cpp-containers = f "luna-cpp-containers" "lib/cpp-containers";
  luna-data-construction = f "luna-data-construction" "lib/data-construction";
  luna-datafile = f "luna-datafile" "lib/datafile";
  luna-data-property = f "luna-data-property" "lib/data-property";
  luna-data-storable = f "luna-data-storable" "lib/data-storable";
  luna-data-tag = f "luna-data-tag" "lib/data-tag";
  luna-data-typemap = f "luna-data-typemap" "lib/data-typemap";
  luna-exception = f "luna-exception" "lib/exception";
  luna-foreign-utils = f "luna-foreign-utils" "lib/foreign-utils";
  luna-future = f "luna-future" "lib/future";
  luna-generic-traversable = f "luna-generic-traversable" "lib/generic-traversable";
  luna-generic-traversable2 = f "luna-generic-traversable2" "lib/generic-traversable2";
  luna-memory-manager = f "luna-memory-manager" "lib/memory-manager";
  luna-memory-pool = f "luna-memory-pool" "lib/memory-pool";
  luna-nested-containers = f "luna-nested-containers" "lib/nested-containers";
  luna-parser-utils = f "luna-parser-utils" "lib/parser-utils";
  luna-syntax-definition = f "luna-syntax-definition" "lib/syntax-definition";
  luna-text-processing = f "luna-text-processing" "lib/text-processing";
  luna-th-builder = f "luna-th-builder" "lib/th-builder";
  luna-tuple-utils = f "luna-tuple-utils" "lib/tuple-utils";
  luna-type-cache = f "luna-type-cache" "lib/type-cache";
  luna-yaml-utils = f "luna-yaml-utils" "lib/yaml-utils";

  # luna
  luna-core = f "luna-core" "core";
  luna-debug = f "luna-debug" "debug";
  luna-package = dontCheck (f "luna-package" "package"); # tests fail
  luna-passes = f "luna-passes" "passes";
  luna-runtime = f "luna-runtime" "runtime";
  luna-stdlib = f "luna-stdlib" "stdlib";
  luna-syntax-text-builder = f "luna-syntax-text-builder" "syntax/text/builder";
  luna-syntax-text-lexer = f "luna-syntax-text-lexer" "syntax/text/lexer";
  luna-syntax-text-model = f "luna-syntax-text-model" "syntax/text/model";
  luna-syntax-text-parser = f "luna-syntax-text-parser" "syntax/text/parser";
  luna-syntax-text-prettyprint = f "luna-syntax-text-prettyprint" "syntax/text/prettyprint";
  # uses githash which needs git at compile time
  luna-shell = addBuildTool (f "luna-shell" "shell") nixpkgs.buildPackages.git;

  ##
  ## luna-studio
  ##

  # config
  luna-api-definition = g "luna-api-definition" "common/api-definition";

  # backend libs
  luna-empire = dontCheck (g "luna-empire" "backend/libs/luna-empire"); # tests fail
  m-logger = g "m-logger" "backend/libs/m-logger";
  zmq-bus = g "zmq-bus" "backend/libs/zmq-bus";
  zmq-bus-config = g "zmq-bus-config" "backend/libs/zmq-bus-config";
  zmq-rpc = g "zmq-rpc" "backend/libs/zmq-rpc";

  # backend services
  luna-broker = g "luna-broker" "backend/services/broker";
  luna-bus-logger = g "luna-bus-logger" "backend/services/bus-logger";
  # missing test dependency on prologue?
  luna-double-representation = dontCheck (g "luna-double-representation" "backend/services/double-representation");
  luna-undo-redo = dontCheck (g "luna-undo-redo" "backend/services/undo-redo");
  luna-ws-connector = g "luna-ws-connector" "backend/services/ws-connector";

  # frontend

  # for luna-studio-runner
  typelevel123 = doJailbreakHpack (self.callCabal2nix "typelevel" (fetchFromGitHub {
    owner = "luna";
    repo = "typelevel";
    rev = "d5c2a68df9b34b8370c98a84f8bcaf311869daa9";
    sha256 = "0i3wyzaddxqz2q7a48kbv47qs0ir43kw86slp92wwrqjmhh0mpvs";
  }) {});
  luna-studio-runner = g "luna-studio-runner" "runner";
  #luna-studio-runner = overrideCabal (g "luna-studio-runner" "runner") (drv: {
  #  executableHaskellDepends = (drv.executableHaskellDepends or []) ++ [self.layered-state];
  #});
}
