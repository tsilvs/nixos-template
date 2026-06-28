# Local CI with act — caching

<!-- links -->

[dev/arch/ci]: ../../../../arch/ci/README.md "CI architecture"
[dev/decisions]: ../../../../decisions/README.md "Design decisions & TODOs"
[todo/1-ci]: ../../../../decisions/todo/1-ci/INDEX.md "CI TODOs"
[act-repo]: https://github.com/nektos/act "nektos/act"
[act-usage]: https://nektosact.com/usage/index.html "act usage guide"
[act-cache-issue]: https://github.com/nektos/act/issues/6120 "Act slow — re-downloading deps"

<!-- doc -->

`act` runs GitHub Actions locally via Docker. Each job gets fresh container — no step-level diff detection, no automatic cache. Three mechanisms to avoid redundant work.

## Quick reference

```bash
act -P ubuntu-latest=ubuntu:24.04 \     # match CI runs-on
    -b \                                # bind-mount workspace (no copy)
    --pull=false \                      # don't re-pull Docker image
    --action-offline-mode               # don't re-fetch actions
```

Additive: `--reuse` preserves container between runs (deps survive). `--cache-server-path` enables `actions/cache@v4` (enabled by default at `~/.cache/actcache`).

## Caching mechanisms

### 1. `actions/cache@v4` — file-level cache

Act runs local cache server (default `~/.cache/actcache`). `actions/cache@v4` in workflow automatically stores/restores cache entries. Cache keys based on `hashFiles(...)`.

**Works for**: `/nix/store` closure, `~/.cache/nix`, `nixpkgs` checkouts.

**Limit**: GitHub-hosted cache is 10GB. Local act cache has no size limit — disk only.

### 2. `--reuse` (`-r`) — container preservation

Don't remove container after run. Filesystem state persists: installed packages, nix store, downloaded tarballs all survive between `act` invocations. Trash container manually (`docker rm`) when done.

**Works for**: iterative dev — install Nix once, run lint/build repeatedly.

**Risk**: stale state pollution. Always test from scratch (`act` without `-r`) before pushing.

### 3. `--bind` (`-b`) — bind-mount workspace

Bind-mounts working directory into container instead of copying. Changes reflected immediately on host. Filesystem I/O is native speed (no Docker overlay copy-on-write).

**Works for**: local iteration — edit `.nix` files, run `act -b` again.

### 4. `--action-offline-mode` — skip remote fetches

Stops pulling Docker images and GitHub Actions if cached locally. Reuses previously downloaded actions from `--action-cache-path` (`~/.cache/act`).

**Works for**: offline work, slow connections, rate-limited GitHub API.

**Pre-req**: run once online first to populate cache.

### 5. `--pull=false` — skip Docker image pull

Act pulls `ubuntu-latest` image every run by default (`--pull=true`). Set false to reuse local image.

### 6. Nix store cache via `actions/cache@v4`

For this pipeline specifically: `/nix/store` is the heaviest object. Caching it avoids re-download + re-build.

```yaml
- uses: actions/cache@v4
  with:
    path: /nix/store
    key: nix-store-${{ runner.os }}-${{ hashFiles('flake.lock') }}
    restore-keys: nix-store-${{ runner.os }}-
```

**Caveat**: `/nix/store` can be many GB. GitHub Actions 10GB cache limit applies. Local act has no limit. Store grows over time — pair with `nix store gc` in workflow.

## This pipeline — what's heavy

| Step | Cost | Cache strategy |
|------|------|----------------|
| `nix-install` tarball download | ~50MB, unpack + copy store | `--reuse` keeps installed Nix |
| `nix run nixpkgs#<tool>` (4 tools) | ~200MB closures each, network-heavy | `--reuse` keeps eval cache; `actions/cache@v4` on `/nix/store` |
| `nix flake check --no-build` | eval cost only, no build | `--reuse` keeps eval cache |
| `nix build .#example-host` | full toplevel build, RAM-heavy | skipped on local act (insufficient RAM); `--reuse` for store |
| `nix store optimise` | dedup hard links | skipped on local act |
| Docker image pull | `ubuntu:24.04`, ~80MB | `--pull=false` |

See [CI architecture doc][dev/arch/ci] for full pipeline details.

## Predictability

`act` determinism depends on:

1. **Pinned inputs**: `flake.lock` committed → same Nixpkgs revision every time
2. **Pinned actions**: `actions/checkout@v7`, `actions/cache@v4` — no floating tags
3. **Pinned Nix version**: tarball URL version-pinned in `nix-install` action
4. **`--reuse` caveat**: container state drifts. Always run final test without `-r` to verify clean build.

## Pre-send check for act runs

```bash
act -n                                    # dry-run: validate workflow YAML
act -P ubuntu-latest=ubuntu:24.04 -b \    # full run, bind-mount
    --pull=false --action-offline-mode
act -P ubuntu-latest=ubuntu:24.04 -b -r \ # reuse container (fast iteration)
    --pull=false --action-offline-mode \
    -j check
```