# nixos-template

<!-- links -->

[sops-nix]: https://github.com/Mic92/sops-nix "sops-nix - NixOS secrets via SOPS"
[age]: https://github.com/FiloSottile/age "age - simple file encryption"
[determinate-nix]: https://github.com/DeterminateSystems/nix-installer "Determinate Systems Nix installer"
[nixos-anywhere]: https://github.com/nix-community/nixos-anywhere "nixos-anywhere - remote provisioning"
[act]: https://github.com/nektos/act "act - run GitHub Actions locally"

<!-- doc -->

NixOS host template. Profile-based identity separation, [sops-nix][sops-nix] secrets, zero-copy CI.

## Features

## Concepts

### Three-tier data model

| Tier                                              | Content                                   | Git                      | Who reads    |
| ------------------------------------------------- | ----------------------------------------- | ------------------------ | ------------ |
| **Logic** `nix/modules/`                          | all module code, zero hardcoded values    | ✅ committed             | anyone       |
| **Identity** `conf/profiles/<host>/variables.nix` | hostname, usernames, IPs, roles, packages | ❌ gitignored            | local only   |
| **Secrets** `conf/secrets/<host>/secrets.yaml`    | passwords, private keys, tokens           | ✅ committed (encrypted) | host age key |

Secrets never enter `/nix/store` (world-readable). `variables.nix` references `/run/secrets/<name>`;
[sops-nix][sops-nix] decrypts to `/run/secrets/` at activation.

### Profile system

`conf/profiles/<name>/variables.nix` - one file per deployment context.

- `example` - committed, safe fake values, CI always builds this
- `<hostname>` - gitignored, real identity values, used on the machine

`flake.nix` enumerates both as named `nixosConfigurations`:

```
nixos-rebuild switch --flake .#<hostname>           # local, real profile
nix build '.#nixosConfigurations.<hostname>-example' # CI, example profile
```

No copy step. No symlinks. Pure Nix path import.

### Submodule layout

Two separate git repos composed via `path:` flake inputs:

- `nix/modules/` - shared logic, independent history (→ `nix-modules` repo)
- `nix/hosts/<hostname>/` - host wiring, independent history (→ `nix-<hostname>` repo)

Root `flake.nix` is the composition layer. `nixos-rebuild switch` always runs from repo root.

---

## Design decisions & open TODOs

| Decision                                                | Status         | Notes                           |
| ------------------------------------------------------- | -------------- | ------------------------------- |
| Profile-based identity separation                       | ✅ implemented | `conf/profiles/`                |
| sops-nix secrets                                        | ✅ wired       | `conf/secrets/` + `default.nix` |
| Root flake (not host sub-flake) as entry point          | ✅ implemented | clean `conf/` paths             |
| CI: no cachix, Determinate Systems installer            | ✅ implemented | `nix-install/action.yml`        |
| CI: example profile, no copy step                       | ✅ implemented | `flake-check/action.yml`        |
| CI: ubuntu-latest (not ubuntu-slim)                     | ✅ fixed       | `ci.yml`                        |
| CI: statix + nixpkgs-lint + ast-grep custom rules       | ✅ implemented | `lint/action.yml`               |
| GitLab CI equivalent                                    | ✅ implemented | `.gitlab-ci.yml`                |
| statix rules enabled                                    | ✅ configured  | `statix.toml`                   |
| SSH cipher policy: widen for compat                     | ✅ widened     | `modules/ssh.nix`               |
| Network unit name: eval-time assertion                  | ✅ added       | `modules/luks-ssh-unlock.nix`   |
| WireGuard: generate standalone `.conf` files            | 🔲 TODO        | see `modules/vpn.nix` header    |
| Overlay VPN: Tailscale/Headscale/Netbird                | 🔲 TODO        | separate modules needed         |
| Nix GC: `nix.gc.automatic` parametrized by `NIX_GC_AGE` | 🔲 TODO        | add to `hardening.nix`          |
