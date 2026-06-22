# Submodule layout

<!-- links -->

[dev/arch/profiles]: ../profiles/README.md "Profile system"
[dev/arch/data-model]: ../data-model/README.md "Three-tier data model"

<!-- doc -->

Two separate git repos composed via `path:` flake inputs:

- `nix/modules/` — shared logic, independent history (→ `nix-modules` repo)
- `nix/hosts/<hostname>/` — host wiring, independent history (→ `nix-<hostname>` repo)

Root `flake.nix` is the composition layer. `nixos-rebuild switch` always runs from repo root.

Host configs import modules and [profiles][dev/arch/profiles] to form complete [data-model][dev/arch/data-model] tier separation.