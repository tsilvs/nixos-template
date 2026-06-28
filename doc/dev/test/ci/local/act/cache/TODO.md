# act caching — TODO

<!-- links -->

[dev/arch/ci]: ../../../../arch/ci/README.md "CI architecture"
[act-readme]: ../README.md "act caching README"

<!-- doc -->

## What to cache

| Priority  | Item                                                     | Why                                                                                            | How                                                                                                                          |
| --------- | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 🔴 High   | `/nix/store`                                             | ~2GB closure re-downloaded every `act` run; dominates wall-clock time                          | `actions/cache@v4` in `ci.yml` with `key: nix-store-${{ runner.os }}-${{ hashFiles('flake.lock') }}`                         |
| 🔴 High   | Nix install tarball                                      | ~50MB download + `tar xJ` + `cp -a store/*` per run                                            | `--reuse` keeps installed Nix in container; or cache tarball via `actions/cache@v4`                                          |
| 🟡 Medium | `nix run nixpkgs#<tool>` closures                        | 4 tools × ~200MB closures each; `alejandra`, `deadnix`, `statix`, `ast-grep` rebuilt every run | If `/nix/store` cached → instant (all tools are in nixpkgs closure); otherwise: custom Docker image with tools pre-installed |
| 🟡 Medium | Docker `ubuntu:24.04` image                              | ~80MB pull every `act` invocation (default `--pull=true`)                                      | `.actrc` with `--pull=false` or `--action-offline-mode`                                                                      |
| 🟢 Low    | GitHub Actions (checkout, submodules, lint, flake-check) | Fetched from GitHub on every `act` run                                                         | `--action-offline-mode` in `.actrc`                                                                                          |
| 🟢 Low    | `nix flake check` eval                                   | Pure eval cost, no network; fast enough without cache                                          | No cache needed; `--reuse` keeps eval cache warm                                                                             |
| ⬜ Skip   | `nix build .#example-host`                               | Skipped on local act (insufficient RAM); runs only on GitHub                                   | Not applicable to act                                                                                                        |

## How — workflow changes

### 1. Add `actions/cache@v4` to `ci.yml`

Insert after `nix-install` step, before lint:

```yaml
- uses: actions/cache@v4
  with:
     path: /nix/store
     key: nix-store-${{ runner.os }}-${{ hashFiles('flake.lock') }}
     restore-keys: |
        nix-store-${{ runner.os }}-
```

**Why after nix-install**: `nix-install` populates `/nix/store` with tarball content. Cache restore/upload wraps the rest of the pipeline.

**Caution on GitHub**: `/nix/store` may exceed 10GB GHA cache limit. Add `nix store gc` step after build to trim. On local act: no limit.

### 2. Add `.actrc`

Repository root `.actrc` for predictable local runs:

```
--pull=false
--action-offline-mode
--container-architecture=linux/amd64
```

Per-developer overrides in `~/.actrc` or `./.actrc` (cwd takes precedence per XDG spec).

### 3. Optional: custom runner image

Bake Nix + lint tools into Docker image once, avoid install entirely:

```bash
# one-time
docker build -t nixos-ci:latest -f- . <<'EOF'
FROM ubuntu:24.04
RUN curl -L https://releases.nixos.org/nix/nix-2.27.2/nix-2.27.2-x86_64-linux.tar.xz | tar xJ && \
    cp -a nix-*/store/* /nix/store/ && \
    ln -s /nix/store/*-nix-*/bin/nix /usr/local/bin/nix
EOF

# then
act -P ubuntu-latest=nixos-ci:latest --pull=false
```

**Tradeoff**: image is large (~3GB with Nix), but eliminates per-run tarball download + unpack. Good for frequent local iteration.

### 4. nix-specific cache warming

For GitHub Actions (not act): warm nix store before running tools:

```yaml
- name: "Warm nix store (pre-fetch)"
  run: |
     sudo nix build nixpkgs#alejandra nixpkgs#deadnix nixpkgs#statix nixpkgs#ast-grep --no-link
```

Pre-builds all 4 tool closures so `nix run` steps are instant. Only useful on GitHub (act can use `--reuse` instead).

## Don't cache these

| Item                              | Reason                                                                    |
| --------------------------------- | ------------------------------------------------------------------------- |
| `~/.cache/act` (action cache dir) | Already handled by `--action-offline-mode`; manual caching is redundant   |
| `/nix/var` (Nix DB)               | Correlates with `/nix/store` — must be consistent; don't cache separately |
| `flake.lock`                      | Committed; changes indicate different deps → new cache key anyway         |
| Git workspace                     | `--bind` already bind-mounts; no copy overhead                            |
| Container state (Docker volumes)  | `--reuse` is simpler; volume management adds complexity                   |

## Priority order

1. `.actrc` — zero code change, immediate speedup (stops image + action pulls)
2. `actions/cache@v4` in `ci.yml` — caches `/nix/store` across runs; works on both GitHub and act
3. Custom runner image — one-time cost, permanent speedup for heavy local use
4. nix store GC step — prevents cache bloat on GitHub (10GB limit)

See [act caching README][act-readme] for mechanism details and [CI architecture][dev/arch/ci] for full pipeline.
