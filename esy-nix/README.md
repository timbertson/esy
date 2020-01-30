# esy2nix

(currently an in-tree esy-nix module in a fork for convenience, but can be broken out into a separate codebase)

# Build

```bash
nix-build -A esy
```

# How it works

1. user generates `esy.lock` and commits to source code
   (or stores it somewhere on disk, doesn't have to be committed)
1. esy2nix processes this file (impurely) and produces derivations in esy-selection.nix
   - uses SolutionLock.ofPath to load the lockfile, and custom code to generate

1. the generated derivations reference each other, and the build commands
   invoke esy2nix. This generates a build plan and runs it directly (or TODO: maybe it invokes esy-build-package?)

Caches:
- during resolution, we can just delegate to esy's global caches for now
- during building, need to set --store-path?
  - if we generate build plans that don't rely on the store, we might not actually need to care?

# loading the lock

SolutionLock
 - Sandbox
   - SandboxSpec
     - ofPath (esy.json?)


 - Project.make

# esy Build process

esy is (mostly) compatible with opam deps, it's just not packaged for opam. So we can use opam2nix for the deps, and dune for the build.

A fork is (currently) required to actually install ocaml modules though, as by default they're all private.

