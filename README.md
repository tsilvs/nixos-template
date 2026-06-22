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

## Annotated file tree

```
nixos-template/
│
├── flake.nix                          # ROOT ENTRY POINT. mkHost factory. Enumerates profiles.
├── flake.lock                         # Locked inputs - commit, never edit by hand.
├── statix.toml                        # Nix linter config - relevant rules enabled.
├── .gitignore                         # Gitignores conf/profiles/*/variables.nix (not example).
├── .gitmodules                        # Submodule declarations (modules + host repos).
│
├── conf/                              # CONFIGURATION DATA - all host-specific values live here.
│   ├── profiles/
│   │   ├── example/
│   │   │   └── variables.nix          # Committed. Fake values. CI target. Schema reference.
│   │   └── <hostname>/                # Gitignored variables.nix. Real identity values.
│   │       └── variables.nix          # ← create this on each machine; never commit.
│   └── secrets/
│       ├── .sops.yaml                 # Age key → file mapping. Committed.
│       └── <hostname>/
│           └── secrets.yaml           # sops-encrypted secrets. Committed (ciphertext only).
│
├── nix/
│   ├── hosts/
│   │   └── <hostname>/                # Git submodule: nix-<hostname> repo.
│   │       ├── default.nix            # MINIMAL. stateVersion + sops secret declarations only.
│   │       └── disko.nix              # Disk layout. Used by nixos-anywhere only, never by rebuild.
│   └── modules/                       # Git submodule: nix-modules repo. All logic lives here.
│       ├── flake.nix                  # Exports nixosModules.default attrset.
│       ├── gocryptfs.nix
│       ├── hardening.nix
│       ├── hardware.nix
│       ├── luks-ssh-unlock.nix
│       ├── network.nix
│       ├── packages.nix
│       ├── roles.nix
│       ├── ssh.nix
│       ├── users.nix
│       └── vpn.nix
│
├── .ci/
│   └── lint/
│       └── nix/
│           └── rules/
│               └── no-hardcoded-ports.yml  # ast-grep rule: flag literal port numbers.
│
└── .github/
    ├── actions/
    │   ├── nix-install/action.yml     # Installs Nix via Determinate Systems. No cachix.
    │   ├── submodules/action.yml      # Clones submodules via GH_PAT (HTTPS override).
    │   ├── lint/action.yml            # alejandra + deadnix + statix + ast-grep.
    │   └── flake-check/action.yml     # nix flake check + build toplevel. No copy step.
    └── workflows/
        └── ci.yml                     # Orchestrates above actions on push/PR.

# Also at root:
# .gitlab-ci.yml                       # GitLab CI equivalent (ubuntu:24.04, manual Nix install).
```

---

## Quick start

### New machine

```bash
# 1. Clone template
git clone <this-repo> nix-<hostname>
cd nix-<hostname>

# 2. Init submodules (replace URLs in .gitmodules first)
git submodule update --init --recursive

# 3. Create real profile (gitignored)
cp conf/profiles/example/variables.nix conf/profiles/<hostname>/variables.nix
# edit conf/profiles/<hostname>/variables.nix - fill real hostname, users, IPs

# 4. Generate age key (first time)
age-keygen -o ~/.config/sops/age/keys.txt
# Add public key to conf/secrets/.sops.yaml

# 5. Create secrets
sops conf/secrets/<hostname>/secrets.yaml
# Fill: admin-password, wg-private-key, initrd-host-key (if LUKS+SSH unlock)

# 6. Add to flake.nix nixosConfigurations (two lines - see flake.nix comments)

# 7. Build
nix flake check
nixos-rebuild switch --flake .#<hostname>
```

### CI secrets required

| Secret   | Purpose                                            |
| -------- | -------------------------------------------------- |
| `GH_PAT` | Read access to private submodule mirrors on GitHub |

### Local act

```bash
act -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

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
