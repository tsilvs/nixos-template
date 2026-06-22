# Code Style

## Format

**alejandra** - standard Nix formatter. Run before commit:

```sh
alejandra nix/
```

## Lint stack

```sh
deadnix --fail nix/           # unused code
statix check .                 # lint rules (config: statix.toml)
ast-grep scan --rule .ci/lint/nix/rules/ nix/  # custom rules
```

## Guidelines

### No hardcoded values in modules

All host-specific params go through `vars` (from `conf/profiles/<host>/variables.nix` via `specialArgs`). Zero literal values in module code. Enforced by ast-grep rule `no-hardcoded-ports`.

### Network: `matchConfig.Type` over `matchConfig.Name`

Interface names are unstable across kernel updates, hardware swaps, hypervisor changes. Use `matchConfig.Type` (`wlan`, `ether`) - an intrinsic property. Exception: fixed-hardware servers where NIC is known; use `vars.serverIface` (parametrized, not literal).

### Priority chain

Roles set defaults via `lib.mkDefault`. Profile `vars.*` override at normal priority. Users can customize without touching module code.

### Secrets

Never enter `/nix/store` (world-readable). Use [sops-nix](https://github.com/Mic92/sops-nix) - decrypts to `/run/secrets/` at activation. Edit with `sops conf/secrets/<host>/secrets.yaml`.

### Activation scripts (sentinel pattern)

One-shot operations use `system.activationScripts` + sentinel file in `/var/lib/nixos/`:

```nix
system.activationScripts.myScript = ''
  SENTINEL=/var/lib/nixos/my-script-done
  if [ -f "$SENTINEL" ]; then exit 0; fi
  # one-shot work
  touch "$SENTINEL"
'';
```

Ensures operations survive rebuilds without re-triggering.

### Scheduled tasks

Use systemd timers + oneshot services, not cron:

```nix
systemd.timers.my-task = {
  wantedBy = [ "timers.target" ];
  timerConfig = { OnCalendar = "daily"; Persistent = true; };
};
systemd.services.my-task = {
  serviceConfig = { Type = "oneshot"; /* ... */ };
};
```

`Persistent=true` ensures missed runs catch up after downtime. Templates (`@`) for parallel instances.

### CI: zero infra deps

No cachix, no external GitHub Actions (beyond `checkout`). Nix installed via `curl | sh`. Builds self-contained - slower but zero external dependency.

### flake.lock committed

Required for reproducible builds. `path:` inputs resolve via git when repo present.

## Files

### Naming

- Module files: lowercase, dash-separated (`hardening.nix`, `luks-ssh-unlock.nix`)
- Host dirs: `nix/hosts/<hostname>/` matching profile name
- Profile files: `conf/profiles/<name>/variables.nix`
- Secret files: `conf/secrets/<name>/secrets.yaml`