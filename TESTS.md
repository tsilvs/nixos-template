# Tests

## Local

### Notes

- `GH_PAT` required only if private submodules not already fetched locally (`git submodule update --init --recursive` via SSH works for local dev).
- First `nix build` is slow (cold store); subsequent runs hit cache.
- To persist act's Nix store across runs, mount a volume: `act --bind` or use a self-hosted runner cache.

### Manual Steps

#### On other distros

##### Reuse `act` OCI image

...

#### On NixOS

```sh
# Lint

alejandra --check nix/
deadnix --fail nix/
statix check .
ast-grep scan nix/

# Flake Check + Build

nix flake check --no-build --override-input nix-modules ./nix/modules

nix build '.#nixosConfigurations.example-host.config.system.build.toplevel' \
 --no-link \
 --override-input nix-modules ./nix/modules
```

### `act`

[CI workflow](.github/workflows/ci.yml)

#### Prerequisites

- [`act`](https://github.com/nektos/act) installed
- Docker or Podman running
- GitHub PAT with `repo` read scope (for private submodule fetch)

#### Run Full CI

```sh
act -P ubuntu-latest=catthehacker/ubuntu:act-latest \
 --secret GH_PAT=<your-pat>
```

#### Run Specific Job

```sh
act -j check \
 -P ubuntu-latest=catthehacker/ubuntu:act-latest \
 --secret GH_PAT=<your-pat>
```

## Remote

### GHA

> GitHub Actions CI

...

### GL-CI

> GitLab CI

...
