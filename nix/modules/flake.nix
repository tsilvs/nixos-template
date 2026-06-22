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

  outputs = _: {
    nixosModules.default = {
      gocryptfs       = _: {};
      hardening       = _: {};
      hardware        = _: {};
      luks-ssh-unlock = _: {};
      network         = _: {};
      packages        = _: {};
      roles           = _: {};
      ssh             = _: {};
      users           = _: {};
      vpn             = _: {};
    };
  };
}
