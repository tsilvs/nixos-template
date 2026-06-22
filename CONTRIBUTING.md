# Contributing

## Getting Started

See [the quick start guide](doc/use/start/README.md).

## Project Scope

NixOS host template. Profile-based identity separation, sops-nix secrets, zero-copy CI. Rewrite of storage-1661832 config targeting improved architecture, extensibility, testability, test coverage, code style enforcement, readability, reliability.

## Development Setup

```sh
git clone --recurse-submodules <repo-url>
cd nixos-template
nix flake check --no-build --override-input nix-modules ./nix/modules
```

## Architecture

- [Three-tier data model](doc/dev/arch/data-model/README.md) - Logic / Identity / Secrets
- [Design principles](doc/dev/arch/principles/README.md) - 8 architectural rules
- [Network design](doc/dev/arch/net/README.md) - no-hardcoded-interface-names
- [Profile system](doc/dev/arch/profiles/README.md) - per-deployment `variables.nix`
- [Submodule layout](doc/dev/arch/submodules/README.md) - `path:` flake inputs composition
- [Design decisions & TODOs](doc/dev/decisions/README.md)

## Code Style

See [Code Style guidelines](doc/dev/contributing/README.md) for formatting, lint stack, architectural conventions, naming rules.

## Testing

See [TESTS](TESTS.md) for:

- [individual lint/build steps](TESTS.md#manual-steps)
- [running CI](TESTS.md#remote)
  - [locally with `act`](TESTS.md#act)
  - [on GHA](TESTS.md#gha)
  - [on GL-CI](TESTS.md#gl-ci)

## Pull Requests

## License
