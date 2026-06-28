# Shared Artifacts TODO

<!-- links -->

[gh:actions/checkout]: https://github.com/actions/checkout "actions/checkout"
[ast-grep:config]: https://ast-grep.github.io/reference/sgconfig.html "sgconfig reference"

<!-- doc -->

Refactor CI actions + `ast-grep` rules into versioned shared repos to eliminate drift.

## TODO

- [ ] Create `org/ast-grep-rules` repo
  - Move rules from `sgconfig.yml` + rule dirs into new repo
  - Structure: `nix/`, `shell/`, `python/` subdirs + root `sgconfig.yml`
  - Tag `v1.0.0`

- [ ] Create `org/actions` repo (composite GitHub Actions)
  - `lint/action.yml`
  - `nix-build/action.yml` — `nix flake check` + build
  - `ast-grep-check/action.yml` — fetches `org/ast-grep-rules` at pinned ref, runs `sg scan`
  - `deploy-nixos/action.yml`
  - Tag `v1.0.0`

- [ ] Update this repo's CI to consume `org/actions/ast-grep-check@v1`
  - Remove inline `ast-grep` invocation
  - Pin rules via action input param

- [ ] Extract NixOS modules → `org/nixos-modules` (defer until ≥2 repos share config)
  - `modules/common.nix`, `server.nix`, `workstation.nix`
  - `overlays/default.nix`
  - Expose via `flake.nix`; consumers pin `inputs.nixos-modules.url = "github:org/nixos-modules/vX.Y.Z"`

- [ ] Write `doc/dev/shared-artifacts.md` — artifact registry table

  | Artifact | Repo | Pin mechanism | Update cadence |
  |---|---|---|---|
  | CI actions | `org/actions` | `@vX` tag | minor monthly |
  | ast-grep rules | `org/ast-grep-rules` | `ref: vX` in action | per rule addition |
  | NixOS modules | `org/nixos-modules` | flake input `vX.Y.Z` | flake update PRs |

- [ ] Write `doc/dev/versioning-policy.md` — semver rules, deprecation lifecycle

## Bootstrap Order

1. `org/ast-grep-rules` → tag `v1.0.0`
2. `org/actions` wrapping rules repo → tag `v1.0.0`
3. Update `nixos-template` CI → use `org/actions/ast-grep-check@v1`
4. Extract NixOS modules (deferred)
5. Fill `doc/dev/shared-artifacts.md`
