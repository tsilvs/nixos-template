# nixos-template

<!-- links -->

[sops-nix]: https://github.com/Mic92/sops-nix "sops-nix - NixOS secrets via SOPS"
<!--
[age]: https://github.com/FiloSottile/age "age - simple file encryption"
[determinate-nix]: https://github.com/DeterminateSystems/nix-installer "Determinate Systems Nix installer"
[nixos-anywhere]: https://github.com/nix-community/nixos-anywhere "nixos-anywhere - remote provisioning"
[act]: https://github.com/nektos/act "act - run GitHub Actions locally"
-->

[doc/use/start]: doc/use/start/README.md "Quick start"
[doc/use/secrets]: doc/use/secrets/README.md "Secrets setup"
[doc/dev/arch/data-model]: doc/dev/arch/data-model/README.md "Three-tier data model"
[doc/dev/arch/profiles]: doc/dev/arch/profiles/README.md "Profile system"
[doc/dev/arch/submodules]: doc/dev/arch/submodules/README.md "Submodule layout"
[doc/dev/decisions]: doc/dev/decisions/README.md "Design decisions & TODOs"

<!-- doc -->

NixOS host template. Profile-based identity separation, [sops-nix][sops-nix] secrets, zero-copy CI.

## Docs

- [Quick start][doc/use/start] — clone, profiles, secrets, build
- [Secrets setup][doc/use/secrets] — age keys, sops, SSH deploy
- [Three-tier data model][doc/dev/arch/data-model] — Logic / Identity / Secrets separation
- [Profile system][doc/dev/arch/profiles] — `variables.nix` per deployment context
- [Submodule layout][doc/dev/arch/submodules] — `path:` flake inputs composition
- [Design decisions & TODOs][doc/dev/decisions] — status table
