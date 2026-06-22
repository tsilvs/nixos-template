# Network design

<!-- links -->

[dev/arch/principles]: ../principles/README.md "Design principles"

<!-- doc -->

Core principle: **no hardcoded interface names**. All routing logic keys on _role_ (the interface holding the default route), not on name, MAC, driver, or any other property.

## Why no hardcoded interface names

Interface names are **never stable**:

- Kernel updates rename interfaces
- Different hardware presents different names
- Moving to different router, VM, or hypervisor changes everything
- udev rules can rename at any time

**Exception**: fixed-hardware servers where NIC is known and unchanging. Even then, use `vars.serverIface` - parametrized, not literal.

## Interface-agnostic routing

Runtime egress interface and gateway resolved dynamically:

```bash
ip route get 1.0.0.0 | awk '{for(i=1;i<=NF;i++) if($i=="via") print $(i+1); exit}'  # gateway
ip route get 1.0.0.0 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}'   # interface
```

`fwmark`-based policy routing is inherently interface-agnostic - traffic marked regardless of which physical interface carries it.

## networkd: `matchConfig.Type` over `matchConfig.Name`

`Type` (`wlan`, `ether`) is intrinsic hardware property - stable across kernel updates, hardware swaps, hypervisor changes. `Name` (`wlp3s0`, `enp2s0`) is udev-assigned label that can change at any time.

```nix
# Desktop: matches any wired or wireless interface by type
systemd.network.networks."20-wlan".matchConfig.Type = "wlan";
systemd.network.networks."10-ether".matchConfig.Type = "ether";

# Server (fixed hardware, documented exception):
systemd.network.networks."10-eth".matchConfig.Name = vars.serverIface;
```

Prefix numbers (`10-`, `20-`) enforce match priority: networkd applies `.network` files in lexicographic order.

## WiFi: iwd, not NetworkManager

`iwd` handles scanning, roaming, remembered networks. NM only enabled when desktop GUI needs `plasma-nm`/GNOME network panel. NM told to leave WireGuard interfaces unmanaged:

```nix
networking.networkmanager.unmanaged = [ "type:wireguard" ];
```

## WireGuard

### Tunnel config approach

Target: standalone `.conf` files per tunnel (not embedded Nix attrsets). Separates routing logic from Nix structure, makes each tunnel independently auditable, allows add/remove by file drop. Standard `wg-quick` `.conf` format.

### State persistence

Per-tunnel statefile in `/var/lib/wg-state/` - whether tunnel was up before reboot. `systemd` oneshot service reads statefile, starts tunnel if marked `up`. `nixos-rebuild switch` clears statefiles to declared defaults.

### GUI toggle

Polkit rule (passwordless `systemctl start/stop wg-quick-*` for `wheel`) + `wg-toggle` script that writes statefile on up/down - last state survives reboot.

### Split tunneling

Domain-based routing via dnsmasq intercept on `127.0.0.1:53` forwarding to systemd-resolved. CIDR-based routing via explicit route tables. Per-UID routing table or network namespace options available for app-level bypass.

```nix
vpn = {
  enable = true;
  tunnels = [{
    name         = "wg0";
    splitRoutes       = [ "10.0.0.0/8" ];
    splitDomainGroups = [ "corp" ];       # → /etc/wg-domains/corp.hosts
    splitDomains      = [ "example.com" ];
  }];
};
```

## DNS leak prevention

Per-tunnel DNS with `resolvectl domain <tunnel> "~."` - resolved uses VPN DNS for `~.` only while tunnel is up. No physical interface name referenced.

## Overlay VPN

Tailscale, Headscale, Netbird as separate modules. Must coexist with existing WireGuard tunnels. DNS conflict with dnsmasq handled by per-tunnel dnsmasq `server=` rules.

See [decisions][dev/decisions] for current status.

[dev/decisions]: ../../decisions/README.md "Design decisions & TODOs"
