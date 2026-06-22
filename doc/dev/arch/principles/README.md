# Design principles

<!-- links -->

[dev/arch/data-model]: ../data-model/README.md "Three-tier data model"
[dev/arch/profiles]: ../profiles/README.md "Profile system"
[dev/arch/submodules]: ../submodules/README.md "Submodule layout"
[dev/arch/net]: ../net/README.md "Network design"
[dev/decisions]: ../../decisions/README.md "Design decisions & TODOs"

<!-- doc -->

Eight architectural rules. All modules follow these. Enforced at review, not runtime.

### 1. Profile-driven single source of truth

All host-specific params in `conf/profiles/<host>/variables.nix` (gitignored), injected via `specialArgs`. Modules are fully host-agnostic - zero hardcoded values in logic files.

See [data-model][dev/arch/data-model] and [profiles][dev/arch/profiles].

### 2. Composable submodule decomposition

Three repos composed via `path:` flake inputs with `follows` for dedup: root template + `nix/modules` (shared logic) + `nix/hosts/<host>` (host wiring). Independent git histories.

See [submodule layout][dev/arch/submodules].

### 3. Role-based additive activation

`roles.nix` defines named roles (`baseline`, `vm-guest`, `service-host`, etc.). Each maps to package groups + service config. Roles are assertion-guarded for mutual exclusion (e.g., vm-guest vs vm-host).

### 4. UI interface filtering

Packages tagged `{ cli; gui; web }`. `headless = cli + web` preset for servers. `uiFilter` + per-group overrides - server never gets GUI packages.

### 5. Composable `nixosModules` export

Host flake exposes `nixosModules.<hostname>` (sans disko) for external composition (e.g., `nixos-anywhere`). Root wrapper exposes only `nixosConfigurations`.

### 6. Eval-time error surfacing

Deny-list in `vars.packages.deny` raises `throw` at eval time - typos caught before any build. Assertions guard incompatible role combos and missing dependencies.

### 7. Imperative ops via idempotent activation scripts

`system.activationScripts` with sentinel files in `/var/lib/nixos/` - ensures one-shot ops (e.g., `passwd --expire`) survive rebuilds without re-triggering.

### 8. Install-time vs runtime separation

`disko.nix` used only by `nixos-anywhere` at provision time; never loaded by `nixos-rebuild switch`. Clean separation of disk layout from ongoing configuration.

## Reference implementations

| Repo                                                                      | Notes                                                    |
| ------------------------------------------------------------------------- | -------------------------------------------------------- |
| [srid/nixos-unified](https://github.com/srid/nixos-unified)               | NixOS+darwin+HM unified, flake-parts, autowiring         |
| [srid/nixos-config](https://github.com/srid/nixos-config)                 | Reference impl of nixos-unified                          |
| [chadac/nix-config-modules](https://github.com/chadac/nix-config-modules) | App+host abstraction, tag-based activation               |
| [olistrik/nixos-config](https://github.com/olistrik/nixos-config)         | Recursive lib/module auto-discovery                      |
| [ibizaman/skarabox](https://github.com/ibizaman/skarabox)                 | flake-parts host scaffolding, SSoT-enforced vars+options |
| [Stunkymonkey/nixos](https://github.com/Stunkymonkey/nixos)               | machines/modules/profiles/pkgs/overlays layout           |
| [firecat53/nixos](https://github.com/firecat53/nixos)                     | Multi-host, ZFS, disko, nixos-anywhere                   |
| [hercules-ci/flake-parts](https://github.com/hercules-ci/flake-parts)     | Meta-module system                                       |

## Conventions from source repo

Conventions carried forward into this rewrite:

- [Network design][dev/arch/net] - `matchConfig.Type` over `matchConfig.Name`, interface-agnostic routing, no hardcoded interface names
- `flake.lock` committed - required for reproducible builds
- Secrets never enter `/nix/store` - [sops-nix][sops-nix] decrypts to `/run/secrets/`
- Zero infra deps in CI - no cachix, no external actions; Nix installed via `curl | sh`
- Ast-grep for custom lint rules - shared AST-query language, not tool-specific DSL
- Systemd templates (`@`) for parallel scheduled tasks; `Persistent=true` for missed-run catch-up
- Sentinel pattern (`/var/lib/nixos/<name>`) for one-shot activation ops
- `lib.mkDefault` for roles, normal priority for profile vars (overridable chain)

[sops-nix]: https://github.com/Mic92/sops-nix "sops-nix"
