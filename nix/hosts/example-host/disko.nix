# nix/hosts/example-host/disko.nix
# ─────────────────────────────────────────────────────────────────────────────
# Disk layout — GPT + BIOS boot stub + ESP + /boot + root (optional LUKS).
# Hybrid layout boots on both legacy BIOS and UEFI VPS hosts.
#
# PROVISIONING ONLY — used by nixos-anywhere at install time.
# Never imported by flake.nix or nixos-rebuild switch.
# nixos-anywhere adds disko.nixosModules.disko externally via nixosModules export.
#
# Disk labels (nixos / boot / ESP / cryptroot) are a provisioning contract
# with nix/modules/hardware.nix which mounts by label.
# ─────────────────────────────────────────────────────────────────────────────
{ lib, vars, ... }:
let
  l       = vars.luks or {};
  useLuks = l.enable or false;
in {
  disko.devices.disk.primary = {
    type   = "disk";
    device = vars.bootDisk;
    content = {
      type = "gpt";
      partitions = {
        # GRUB core.img slot — no filesystem; required for GPT + legacy BIOS.
        bios = {
          size = "1M";
          type = "EF02";
        };

        # EFI System Partition — GRUB EFI loader for UEFI hosts.
        esp = {
          size = "512M";
          type = "EF00";
          content = {
            type         = "filesystem";
            format       = "vfat";
            mountpoint   = "/boot/efi";
            mountOptions = [ "umask=0077" ]; # FAT has no native perms; restrict to root
            extraArgs    = [ "-n" "ESP" ];
          };
        };

        # Plaintext /boot — kernels + initrds outside LUKS so GRUB reads grub.cfg
        # without prompting for passphrase (GRUB cryptomount not emitted for /boot
        # when it is on a separate unencrypted partition).
        boot = {
          size = "1G";
          content = {
            type       = "filesystem";
            format     = "ext4";
            mountpoint = "/boot";
            extraArgs  = [ "-L" "boot" ];
          };
        };

        # Root partition — optionally LUKS-wrapped.
        root = {
          size = "100%";
          content =
            if useLuks then
              ({
                type                   = "luks";
                name                   = l.device or "cryptroot";
                settings.allowDiscards = l.ssd or false;
                extraFormatArgs        = [ "--label" "cryptroot" ];
                content = {
                  type       = "filesystem";
                  format     = vars.rootFsType;
                  mountpoint = "/";
                  extraArgs  = [ "-L" "nixos" ];
                };
              # keyFile: path on TARGET before disko runs.
              # Supply via nixos-anywhere --disk-encryption-keys.
              } // lib.optionalAttrs (l ? passwordFile) { inherit (l) passwordFile; })
            else {
              type       = "filesystem";
              format     = vars.rootFsType;
              mountpoint = "/";
              extraArgs  = [ "-L" "nixos" ];
            };
        };
      };
    };
  };
}
