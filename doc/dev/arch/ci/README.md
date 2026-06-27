# CI Architecture

<!-- links -->

[dev/decisions]: ../../decisions/README.md "Design decisions & TODOs"
[dev/arch/principles]: ../principles/README.md "Design principles"

<!-- doc -->

Two-stage pipeline: `lint` → `check`. Targets GitHub Actions and GitLab CI.

## Pipeline structure

```
lint                         check
──────────────────────────   ──────────────────────────────────────
alejandra  --check nix/      nix flake check --no-build
deadnix    --fail  nix/      nix build .#example-host.toplevel
statix     check .
ast-grep   scan   nix/
```

## Nix install — GitHub Actions

No Nix daemon. No `cachix`. Manual tarball install (`.github/actions/nix-install/action.yml`):

| Step           | Command                                                                     | Reason                                                                                        |
| -------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Download       | `curl releases.nixos.org/nix/.../nix-VERSION-x86_64-linux.tar.xz \| tar xJ` | version-pinned; no installer script side-effects                                              |
| Store populate | `sudo cp -a store/* /nix/store/`                                            | copies pre-built closure; skips `nix-env` profile build (OOMs in constrained containers)      |
| Permissions    | `sudo chown -R $(id -u):$(id -g) /nix/store /nix/var`                       | runner must own store for writes                                                              |
| DB dir         | `mkdir -p /nix/var/nix/db`                                                  | pre-create prevents Nix entering non-root fallback mode (see below)                           |
| Symlink        | `sudo ln -sf $NIX_BIN /usr/local/bin/nix`                                   | `sudo` uses `secure_path`; runner's `PATH` not inherited; symlink makes `sudo nix` resolvable |

### Why `sudo nix` for every command

**Error 1:** `error: mounting '/home/runner/.local/share/nix/root/nix/store' on '/nix/store': Permission denied`

Nix ≥ 2.20 non-root store feature: when run as non-root, Nix creates `~/.local/share/nix/root/nix/store` and bind-mounts it over `/nix/store` via `CLONE_NEWNS`. GHA runners lack `CAP_SYS_ADMIN` → mount fails. Running `sudo nix` makes root the caller; root uses `/nix/store` directly, skipping this path.

**Error 2:** `error: opening lock file "/nix/var/nix/db/big-lock": Permission denied`

`sudo nix` in the lint step creates `/nix/var/nix/db/big-lock` owned by root. A subsequent non-root `nix` command (e.g., in flake-check) cannot acquire the lock. Fix: all steps use `sudo nix` consistently — root owns all lock files, no contention.

**Error 3:** `sudo: nix: command not found`

`sudo` resets `PATH` to `secure_path` (`/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`). The nix binary in `/nix/store/.../bin/nix` is absent from this path. Fix: `sudo ln -sf $NIX_BIN /usr/local/bin/nix` puts it in `secure_path`.

## Lint stage

`.github/actions/lint/action.yml`. All tools fetched via `nix run nixpkgs#<tool>` — no pre-install.

| Tool        | Invocation     | Purpose                                         |
| ----------- | -------------- | ----------------------------------------------- |
| `alejandra` | `--check nix/` | format check, no writes                         |
| `deadnix`   | `--fail nix/`  | unused binding detection                        |
| `statix`    | `check .`      | idiomatic Nix patterns (`statix.toml` config)   |
| `ast-grep`  | `scan nix/`    | custom structural rules (`.ci/lint/nix/rules/`) |

On push to `main`, a preceding auto-format step runs `alejandra` in write mode and commits any diff as `style: auto-format with alejandra [skip ci]`.

## Flake-check stage

`.github/actions/flake-check/action.yml`. Always targets `example-host` nixosConfiguration.

1. `nix flake check --no-build` — evaluates all nixosConfigurations, checks attribute types.
2. `nix build .#nixosConfigurations.example-host.config.system.build.toplevel --no-link` — full toplevel build. Skipped on local `act` runner (insufficient RAM).
3. `nix store optimise` — deduplicates hard links; saves space on self-hosted runners. Skipped on `act`.

`conf/profiles/example/variables.nix` is committed. No copy step — `example-host` imports it directly.

## Host config CI stubs

`nix/hosts/example-host/default.nix` carries minimal stubs to satisfy NixOS eval without real hardware:

```nix
fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
boot.loader.grub.device = "nodev";
```

NixOS requires `fileSystems` and a bootloader declaration to pass type-checking during `nix flake check`. These stubs satisfy the evaluator. Real values come from disko/nixos-anywhere at deploy time and never enter `/nix/store`.

## GitLab CI

`.gitlab-ci.yml` mirrors the GHA workflow with one difference in Nix install: uses the official installer script with systemd detection:

```bash
if pidof systemd >/dev/null 2>&1 || [ -d /run/systemd/system ]; then
  sh -s -- --daemon          # multi-user; systemd manages daemon
else
  sh -s -- --no-daemon       # single-user; container without init
fi
```

GitLab jobs run as root inside `ubuntu:24.04` — no `sudo` prefix needed, non-root store mount never triggered.
