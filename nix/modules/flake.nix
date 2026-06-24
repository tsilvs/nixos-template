# nix/modules/flake.nix
# ─────────────────────────────────────────────────────────────────────────────
# STUB - replace this directory with your actual nix-modules git submodule.
#
# In a real setup this is a separate git repo (e.g., github:OWNER/nix-modules)
# declared in .gitmodules and referenced as `path:./nix/modules` in root flake.nix.
#
# The real flake exports all shared NixOS modules:
#   nixosModules.default = { gocryptfs; hardening; hardware; luks-ssh-unlock;
#                             network; packages; roles; ssh; users; vpn; }
# ─────────────────────────────────────────────────────────────────────────────
{
  description = "Shared NixOS modules - STUB. Replace with real submodule.";

  # outputs fn receives `self`; stub doesn't need it → discard with `_`.
  outputs = _: {
    # `nixosModules` is a reserved flake output key — Nix tooling
    # (nixos-rebuild, flake check) only recognizes this exact name.
    # Renaming to anything shorter breaks auto-resolution. Path in root flake:
    #   nix-modules (input alias) → nixosModules (reserved key) → default (bundle convention).
    nixosModules.default = {
      # Each module is a NixOS module function (takes config/pkgs/... attrs).
      # Stubs discard args and return empty attrset — no-op at build time.
      # TODO: Replace `_: {}` with real function calls.
      gocryptfs = _: {};
      hardening = _: {};
      hardware = _: {};
      luks-ssh-unlock = _: {};
      network = _: {};
      packages = _: {};
      roles = _: {};
      ssh = _: {};
      users = _: {};
      vpn = _: {};
    };
  };
}
