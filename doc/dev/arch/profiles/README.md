# Profile system

<!-- links -->

[dev/arch/data-model]: ../data-model/README.md "Three-tier data model"

<!-- doc -->

`conf/profiles/<name>/variables.nix` — one file per deployment context.

- `example` — committed, safe fake values, CI always builds this
- `<hostname>` — gitignored, real identity values, used on the machine

`flake.nix` enumerates both as named `nixosConfigurations`:

```
nixos-rebuild switch --flake .#<hostname>           # local, real profile
nix build '.#nixosConfigurations.<hostname>-example' # CI, example profile
```

No copy step. No symlinks. Pure Nix path import.

Profiles implement the Identity tier of the [three-tier data model][dev/arch/data-model].