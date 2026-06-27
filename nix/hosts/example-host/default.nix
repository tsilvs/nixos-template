# nix/hosts/example-host/default.nix
# ─────────────────────────────────────────────────────────────────────────────
# Host-specific NixOS configuration.
# Keep minimal - all logic belongs in nix/modules/.
# This file: stateVersion + sops secret declarations only.
#
# secretsFile injected as specialArg from root flake.nix so paths resolve
# relative to the flake root, not relative to this file.
# ─────────────────────────────────────────────────────────────────────────────
{secretsFile, ...}: {
  system.stateVersion = "25.11";

  # Minimal stubs required for nixosConfigurations eval in CI.
  # Real values come from disko / nixos-anywhere on actual deployment.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub.device = "nodev";

  # sops-nix: decrypt secrets from conf/secrets/<hostname>/secrets.yaml
  # to /run/secrets/ at activation. Never enters /nix/store.
  #
  # Host identity: uses /etc/ssh/ssh_host_ed25519_key as the age identity
  # (generated on first boot). Matches the age pubkey in conf/secrets/.sops.yaml.
  sops = {
    defaultSopsFile = secretsFile;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      admin-password = {
        # Declare each secret used in variables.nix.
        # Path: /run/secrets/<name>  (default, owned root:root 0400)
      };
      wg-private-key = {mode = "0400";};
      initrd-host-key = {
        # initrd SSH host key for LUKS remote unlock.
        # Only relevant when vars.luks.sshUnlock = true.
        path = "/etc/secrets/initrd/hostkey.ed25519";
        mode = "0400";
      };
    };
  };
}
