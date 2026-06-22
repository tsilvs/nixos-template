# 1.CI - open TODOs

<!-- doc -->

- [ ] **no `cachix`** - avoid cachix dependency; use only GitHub Actions cache or no cache.
- [ ] **Plain `nix` installer** - use **only official Nix installer** with necessary patches; no extra tooling.
- [ ] **`statix`** - run `statix check` in CI for linting Nix files.
- [ ] **`alejandra`** - run `alejandra --check` in CI for formatting enforcement.
- [ ] **`ast-grep` custom rules** - author and enforce custom ast-grep rules for Nix patterns.
- [ ] **GitLab CI equivalent** - provide a `.gitlab-ci.yml` mirroring the GitHub Actions workflow.
- [ ] **`deadnix` unused code check** - run `deadnix` to detect unused bindings.
- [ ] **`nixpkgs-lint` integration** - optional lint pass with nixpkgs-lint.
- [ ] **`nix store optimise` final step** - run `nix store optimise` as final CI step to deduplicate.
