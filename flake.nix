{
  description = "NixOS host template - profile-based identity, sops-nix secrets, zero-copy CI";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-25.11";
    nix-modules.url = "path:./nix/modules";
    sops-nix.url    = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-modules, sops-nix, ... }:
    let
      # Alias for brevity.
      # Path: nix-modules(input alias) → nixosModules(reserved flake output key
      #   Nix tooling auto-resolves only `nixosModules.<name>`; renaming breaks it)
      #   → default(convention: all modules bundled under one key).
      m = nix-modules.nixosModules.default;
      # TODO: replace ./nix/modules stub with real git submodule (github:OWNER/nix-modules).

      # Shared module list - identical across all host configurations.
      # disko.nix intentionally absent: used by nixos-anywhere only, never by nixos-rebuild.
      hostModules = hostname: [
        ./nix/hosts/${hostname}/default.nix
        sops-nix.nixosModules.sops
        m.gocryptfs
        m.hardening
        m.hardware
        m.luks-ssh-unlock
        m.network
        m.packages
        m.roles
        m.ssh
        m.users
        m.vpn
      ];

      # Build a NixOS configuration for a given hostname + profile.
      #
      # hostname - subdirectory under nix/hosts/
      # profile  - subdirectory under conf/profiles/  (must contain variables.nix)
      #
      # secretsFile is passed as specialArg so default.nix can reference it
      # without constructing paths relative to nix/hosts/<hostname>/.
      mkHost = hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            vars = import ./conf/profiles/${hostname}/variables.nix;
            secretsFile = ./conf/secrets/${hostname}/secrets.yaml;
          };
          modules = hostModules hostname;
        };
    in
    {
      # ── Configurations ────────────────────────────────────────────────────
      # Convention:
      #   <hostname>                        - real profile (gitignored variables.nix, for the machine itself)
      #   example, <hostname>-example       - example profile (committed, CI build target)
      #
      # Add one pair of lines per host.
      # ─────────────────────────────────────────────────────────────────────
      nixosConfigurations = {
        example-host         = mkHost "example-host"; # committed vars, CI
      };

      # ── Module export ─────────────────────────────────────────────────────
      # Exposes the host config as a NixOS module for external composition
      # (e.g., nixos-anywhere adds disko.nixosModules.disko on top without
      # coupling the host repo to disko directly).
      nixosModules.example-host = {
        imports = hostModules "example-host";
      };
    };
}
