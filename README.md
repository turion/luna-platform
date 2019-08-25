# luna-platform

This aims to build the essential parts of luna (https://luna-lang.org/), in particular luna-studio. 

Help is needed to make this work. If you'd like to see luna added to `nixpkgs`, have a look here: https://github.com/NixOS/nixpkgs/issues/63895 and help us out.

To build the current work in progress, clone the repo and inside it, run: `nix run '(import ./. {}).ghc.luna-studio-runner'`
