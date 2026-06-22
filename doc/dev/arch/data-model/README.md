# Three-tier data model

<!-- links -->

[sops-nix]: https://github.com/Mic92/sops-nix "sops-nix - NixOS secrets via SOPS"

[dev/arch/profiles]: ../profiles/README.md "Profile system"

<!-- doc -->

| Tier                                              | Content                                   | Git                      | Who reads    |
| ------------------------------------------------- | ----------------------------------------- | ------------------------ | ------------ |
| **Logic** `nix/modules/`                          | all module code, zero hardcoded values    | ✅ committed             | anyone       |
| **Identity** `conf/profiles/<host>/variables.nix` | hostname, usernames, IPs, roles, packages | ❌ gitignored            | local only   |
| **Secrets** `conf/secrets/<host>/secrets.yaml`    | passwords, private keys, tokens           | ✅ committed (encrypted) | host age key |

Secrets never enter `/nix/store` (world-readable). `variables.nix` references `/run/secrets/<name>`;
[sops-nix][sops-nix] decrypts to `/run/secrets/` at activation.

Identity tier uses the [profile system][dev/arch/profiles] for per-host configuration.