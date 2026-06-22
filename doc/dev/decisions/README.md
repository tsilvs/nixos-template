# Design decisions & open TODOs

<!-- links -->

[dev/arch/data-model]: ../arch/data-model/README.md "Three-tier data model"
[dev/arch/profiles]: ../arch/profiles/README.md "Profile system"
[dev/arch/submodules]: ../arch/submodules/README.md "Submodule layout"
[use/secrets]: ../../use/secrets/README.md "How to use: secrets"

<!-- doc -->

| Scope  | Priority  | Decision                                                | TODO   | Status   | Notes                      |
|--------|-----------|---------------------------------------------------------|--------|----------|----------------------------|
| 0.Arch | High      | Three-tier data model                                   | [TODO] | [x] DONE | [doc][dev/arch/data-model] |
| 0.Arch | High      | Profile-based identity separation                       | [TODO] | [x] DONE | [doc][dev/arch/profiles]   |
| 0.Arch | Medium    | Submodule layout                                        | [TODO] | [ ] TODO | [doc][dev/arch/submodules] |
| 0.Arch | High      | `sops-nix` secrets                                      | [TODO] | [x] DONE | [How to][use/secrets]      |
| 0.Arch | Undefined | ONLY root `flake` as entry point                        | [TODO] | [ ] TODO | [doc]                      |
| 1.CI   | High      | example profile                                         | [TODO] | [х] DONE | [doc]                      |
| 1.CI   | High?     | `ubuntu-latest`                                         | [TODO] | [x] DONE | [doc]                      |
| 1.CI   | High      | no `cachix`                                             | [TODO] | [ ] TODO | [doc]                      |
| 1.CI   | High      | Plain `nix` installer                                   | [TODO] | [ ] TODO | [doc]                      |
| 1.CI   | High      | `statix`                                                | [TODO] | [ ] TODO | [doc]                      |
| 1.CI   | Medium    | `alejandra`                                             | [TODO] | [ ] TODO | [doc]                      |
| 1.CI   | High      | `ast-grep` custom rules                                 | [TODO] | [ ] TODO | [doc]                      |
| 1.CI   | Low       | GitLab CI equivalent                                    | [TODO] | [ ] TODO | [doc]                      |
| 2.Sec  | Medium    | SSH cipher policy: widen for compat                     | [TODO] | [ ] TODO | [doc]                      |
| 3.Net  | High      | Network unit name: eval-time assertion                  | [TODO] | [ ] TODO | [doc]                      |
| 3.Net  | Undefined | WireGuard: generate standalone `.conf` files            | [TODO] | [ ] TODO | [doc]                      |
| 3.Net  | Undefined | Overlay VPN: Tailscale/Headscale/Netbird                | [TODO] | [ ] TODO | [doc]                      |
| ???    | Undefined | Nix GC: `nix.gc.automatic` parametrized by `NIX_GC_AGE` | [TODO] | [ ] TODO | [doc]                      |
