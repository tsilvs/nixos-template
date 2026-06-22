# conf/profiles/example/variables.nix
# ─────────────────────────────────────────────────────────────────────────────
# COMMITTED EXAMPLE PROFILE - safe fake values only.
# Used by CI (builds nixosConfigurations.<hostname>-example).
# Schema reference for creating real profiles.
#
# To create a real profile:
#   cp conf/profiles/example/variables.nix conf/profiles/<hostname>/variables.nix
#   # edit: fill real hostname, usernames, IPs, roles
#   # add secrets to conf/secrets/<hostname>/secrets.yaml via: sops conf/secrets/<hostname>/secrets.yaml
# ─────────────────────────────────────────────────────────────────────────────
{
  # ── Network identity ──────────────────────────────────────────────────────
  serverHostname    = "example-host";
  serverDomain      = "example.com";
  serverIface       = "ens3";
  serverIp          = "203.0.113.1";     # TEST-NET-3 (RFC 5737) - documentation range
  serverPrefix      = 24;
  serverGateway     = "203.0.113.254";
  nameserversPrimary  = [ "9.9.9.9" "149.112.112.112" ];
  nameserversFallback = [ "1.1.1.1" "8.8.8.8" ];

  # ── SSH ───────────────────────────────────────────────────────────────────
  permitRootLogin        = "prohibit-password"; # `yes` | `no` | `prohibit-password` | `forced-commands-only`
  passwordAuthentication = false;               # false = pubkey-only (recommended)

  # ── Disk ──────────────────────────────────────────────────────────────────
  bootDisk   = "/dev/vda";
  rootFsType = "ext4";

  # ── Boot / initrd ─────────────────────────────────────────────────────────
  boot = {
    efiSupport             = true;   # false for legacy-BIOS-only VPS
    efiInstallAsRemovable  = true;   # required when VPS blocks NVRAM writes
    initrdAvailableModules = [ "virtio_net" "virtio_pci" "virtio_blk" "virtio_scsi" ];
    initrdKernelModules    = [];
  };

  # ── Groups ────────────────────────────────────────────────────────────────
  # Extra system groups (created before users). Fields: name (required), gid (optional).
  groups = [];

  # ── Shells ────────────────────────────────────────────────────────────────
  # System-wide login shells to install. Union of this + shells declared in users[].
  # Supported: "bash" "zsh" "fish" "git-shell"
  shells = [ "bash" ];

  # ── Users ─────────────────────────────────────────────────────────────────
  # passwordFile: path to sops secret at /run/secrets/<name> (set by sops-nix at activation).
  # Never put plaintext passwords here - they would end up in /nix/store (world-readable).
  #
  # Fields:
  #   name              required
  #   passwordFile      path to /run/secrets/<name>; empty string = no password
  #   passChangePrompt  true → expire password on first login (force change)
  #   pubkeys           list of SSH authorized key strings
  #   sudo              true → add to wheel
  #   sudoPasswordRequired  true → sudo requires password
  #   userGroup         true → create same-name primary group
  #   shell             "bash" | "zsh" | "fish" | "git-shell"
  #   home              override default /home/<name>
  #   uiHidden          true → AccountsService SystemAccount=true (hide from GDM/SDDM)
  #   groups            extra group memberships
  users = [
    {
      name             = "admin";
      passwordFile     = "/run/secrets/admin-password";
      passChangePrompt = false;
      pubkeys          = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJpHudMRvzbFWF08VoGgCwY9a2BHZc+qBrgRAIFcqNE admin@example-host" ];
      sudo             = true;
      sudoPasswordRequired = false;
      userGroup        = true;
      shell            = "bash";
    }
  ];

  # ── Path ownership ────────────────────────────────────────────────────────
  # systemd-tmpfiles entries. type: "d" create-if-missing (default), "z" relabel, "f" create-file.
  paths = [];

  # ── LUKS full-disk encryption ─────────────────────────────────────────────
  # sshUnlock=true requires enable=true. initrd SSH host key via sops: /run/secrets/initrd-host-key.
  luks = {
    enable       = false;
    sshUnlock    = false;
    device       = "cryptroot";         # name under /dev/mapper/
    ssd          = false;               # true → allowDiscards (TRIM)
    sshPort      = 2222;                # initrd SSH port; keep ≠ 22 (avoids host-key conflict)
    hostKey      = "";                  # initrd SSH host pubkey (set via sops in real profile)
    passwordFile = "/tmp/luks.key";     # used by nixos-anywhere --disk-encryption-keys
  };

  # ── gocryptfs encrypted directory ────────────────────────────────────────
  crypt = {
    enable    = false;
    store     = "/var/lib/crypt/store";
    mount     = "/var/lib/crypt/mount";
    keyfile   = "/etc/gocryptfs.key";
    shared    = false;
    owner     = "";
    extraOpts = "";
    user      = "root";
  };

  # ── WireGuard VPN ─────────────────────────────────────────────────────────
  # privateKeyFile: path to sops secret at /run/secrets/wg-private-key.
  # tunnels[]: one entry per WireGuard interface.
  # splitRoutes, splitDomainGroups, splitDomains: policy routing per tunnel.
  vpn = {
    enable         = false;
    privateKeyFile = "/run/secrets/wg-private-key";
    domainsDir     = "/etc/wg-domains";
    tunnels        = [
      # {
      #   name        = "wg0";
      #   address     = [ "10.8.0.2/24" ];
      #   dns         = "10.8.0.1";
      #   publicKey   = "...";
      #   allowedIPs  = [ "0.0.0.0/0" "::/0" ];
      #   endpoint    = "vpn.example.com:51820";
      #   splitRoutes = [ "10.0.0.0/8" ];
      #   splitDomainGroups = [];
      #   splitDomains      = [];
      # }
    ];
  };

  # ── Network services ──────────────────────────────────────────────────────
  # net.l7 (IANA protocol defaults: port, transport, external) lives in the
  # module — not per-host. Override there only if IANA defaults are wrong.
  net = {
    # Per-host service instances.
    # Fields:
    #   l7        required — IANA protocol name: "http" "https" "ssh" "postgres" "redis" …
    #   port      override l7 default port
    #   ip        override bind address; default: external→serverIp, internal→127.0.0.1
    #   external  override firewall exposure; default inherited from l7 definition
    services = {
      # nginx  = { l7 = "https";                  external = true;  };  # port=443 from l7
      # gitea  = { l7 = "http";  port = 3000;     external = false; };
      # pg-alt = { l7 = "postgres"; port = 5442;  external = false; };
    };

    # Reverse proxy path routing.
    # Values: net.services key. Module resolves name → bind address for upstream.
    proxy = {
      # "/"       = "homepage";
      # "/gitea/" = "gitea";
    };
  };

  # ── Roles ─────────────────────────────────────────────────────────────────
  # Additive on top of baseline. Each role enables package groups + services.
  # baseline always enabled. Roles are assertion-guarded for mutual exclusion.
  roles = {
    baseline     = { enable = true; };
    direct-host  = { enable = false; };
    vm-host      = { enable = false; nestedVirt = false; hugePageCount = 0; };
    vm-guest     = { enable = true; hypervisor = "qemu"; };
    service-host = { enable = false; engine = "docker"; };
    ai-server    = { enable = false; gpu = "cpu"; host = "127.0.0.1"; port = 11434; };
    ai-client    = { enable = false; ollamaUrl = "http://127.0.0.1:11434"; webui = false; };
    gaming       = { enable = false; };
    re           = { enable = false; };
    dev          = { enable = false; };
    ci           = { enable = false; };
    vnc          = { enable = false; display = ":1"; resolution = "1920x1080x24"; };
    desktop      = { enable = false; };
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  packages = {
    # Extra named groups beyond those activated by roles.
    # Valid: base shell monitoring storage archive network security
    #        container proxy dev ci vnc desktop gaming emulation
    #        virtualisation vm-guest-tools hw-tools re ai-inference ai-client-tools
    groups = [];

    # Global UI interface filter applied to all enabled groups.
    # all | cli | gui | web | headless (headless = cli + web; canonical server preset)
    uiFilter = "headless";

    # Per-group overrides - take precedence over uiFilter.
    groupFilters = {};

    # Extra packages by nixpkgs attribute name (dot-separated). Typos → eval-time error.
    extra = [];

    # Packages to exclude even if their group is enabled. Typos → eval-time error.
    deny = [];
  };

  # ── CPU microcode ─────────────────────────────────────────────────────────
  cpu.vendor = "amd"; # "amd" | "intel"
}
