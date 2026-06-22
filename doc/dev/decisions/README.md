# Design decisions & open TODOs

<!-- links -->

[dev/arch/data-model]: ../arch/data-model/README.md "Three-tier data model"
[dev/arch/profiles]: ../arch/profiles/README.md "Profile system"
[dev/arch/submodules]: ../arch/submodules/README.md "Submodule layout"
[dev/arch/principles]: ../arch/principles/README.md "Design principles"
[dev/arch/net]: ../arch/net/README.md "Network design"
[use/secrets]: ../../use/secrets/README.md "How to use: secrets"
[todo/0-arch]: todo/0-arch/INDEX.md "Architecture TODOs"
[todo/1-ci]: todo/1-ci/INDEX.md "CI TODOs"
[todo/2-sec]: todo/2-sec/INDEX.md "Security TODOs"
[todo/3-net]: todo/3-net/INDEX.md "Network TODOs"
[todo/4-pkgs]: todo/4-pkgs/INDEX.md "Packages TODOs"
[todo/5-conf]: todo/5-conf/INDEX.md "Config TODOs"
[todo/6-svc]: todo/6-svc/INDEX.md "Services TODOs"
[todo/7-gc]: todo/7-gc/INDEX.md "Garbage-collection TODOs"

<!-- doc -->

| Scope  | Priority  | Decision                                                | TODO                | Status   | Notes                      |
|--------|-----------|---------------------------------------------------------|---------------------|----------|----------------------------|
| 0.Arch | High      | Three-tier data model                                   | [TODO]              | [x] DONE | [doc][dev/arch/data-model] |
| 0.Arch | High      | Profile-based identity separation                       | [TODO]              | [x] DONE | [doc][dev/arch/profiles]   |
| 0.Arch | High      | Design principles: 8 architectural rules                | [TODO]              | [x] DONE | [doc][dev/arch/principles] |
| 0.Arch | High      | Network design: no-hardcoded-interface-names            | [TODO]              | [x] DONE | [doc][dev/arch/net]        |
| 0.Arch | Medium    | Submodule layout                                        | [TODO][todo/0-arch] | [ ] TODO | [doc][dev/arch/submodules] |
| 0.Arch | High      | `sops-nix` secrets                                      | [TODO]              | [x] DONE | [How to][use/secrets]      |
| 0.Arch | Undefined | ONLY root `flake` as entry point                        | [TODO][todo/0-arch] | [ ] TODO | [doc]                      |
| 1.CI   | High      | example profile                                         | [TODO]              | [х] DONE | [doc]                      |
| 1.CI   | High?     | `ubuntu-latest`                                         | [TODO]              | [x] DONE | [doc]                      |
| 1.CI   | High      | no `cachix`                                             | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 1.CI   | High      | Plain `nix` installer                                   | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 1.CI   | High      | `statix`                                                | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 1.CI   | Medium    | `alejandra`                                             | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 1.CI   | High      | `ast-grep` custom rules                                 | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 1.CI   | Low       | GitLab CI equivalent                                    | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 1.CI   | High      | `deadnix` unused code check                             | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 1.CI   | Low       | `nixpkgs-lint` integration                              | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 1.CI   | Low       | `nix store optimise` final step                         | [TODO][todo/1-ci]   | [ ] TODO | [doc]                      |
| 2.Sec  | Medium    | SSH cipher policy: widen for compat                     | [TODO][todo/2-sec]  | [ ] TODO | [doc]                      |
| 3.Net  | High      | Network unit name: eval-time assertion                  | [TODO][todo/3-net]  | [ ] TODO | [doc]                      |
| 3.Net  | High      | Firewall: UDP + range support (not just TCP)            | [TODO][todo/3-net]  | [ ] TODO | [doc]                      |
| 3.Net  | High      | VPN peers: WireGuard split-tunnel domain routing        | [TODO][todo/3-net]  | [ ] TODO | [doc]                      |
| 3.Net  | Medium    | WireGuard: generate standalone `.conf` files            | [TODO][todo/3-net]  | [ ] TODO | [doc]                      |
| 3.Net  | Low       | Overlay VPN: Tailscale/Headscale/Netbird                | [TODO][todo/3-net]  | [ ] TODO | [doc]                      |
| 4.Pkgs | High      | Overlay VPN groups: Tailscale/Headscale/Netbird pkgs    | [TODO][todo/4-pkgs] | [ ] TODO | [doc]                      |
| 4.Pkgs | High      | Gaming refactor: `gaming` → 8 groups                    | [TODO][todo/4-pkgs] | [ ] TODO | [doc]                      |
| 4.Pkgs | Medium    | New groups: media/creative/comms/office/system (~30)    | [TODO][todo/4-pkgs] | [ ] TODO | [doc]                      |
| 5.Conf | Medium    | Wine/Proton `.exe` execution glue (MIME, binfmt, xdg)   | [TODO][todo/5-conf] | [ ] TODO | [doc]                      |
| 5.Conf | Low       | `direnv` + `nix-your-shell` shell integration           | [TODO][todo/5-conf] | [ ] TODO | [doc]                      |
| 5.Conf | Low       | AI agent runner: opencode serve + tmux + systemd        | [TODO][todo/5-conf] | [ ] TODO | [doc]                      |
| 6.Svc  | Low       | Git bare repo autopull: systemd timer + oneshot         | [TODO][todo/6-svc]  | [ ] TODO | [doc]                      |
| 6.Svc  | Medium    | idempotent activation scripts: sentinel pattern         | [TODO][todo/6-svc]  | [ ] TODO | [doc][dev/arch/principles] |
| 7.GC   | Low       | Nix GC: `nix.gc.automatic` parametrized by `NIX_GC_AGE` | [TODO][todo/7-gc]   | [ ] TODO | [doc]                      |
