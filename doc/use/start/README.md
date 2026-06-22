# Quick start

## Pre-requisites

### Installed commands

```
act
age
sops
```

### CI Secrets

| Secret   | Purpose                                            |
| -------- | -------------------------------------------------- |
| `GH_PAT` | Read access to private submodule mirrors on GitHub |

## Make a New machine config

```bash
# Clone template
git -C $your_local_repo_root clone $this_repo nix-$hostname
cd $your_local_repo_root/nix-$hostname

# Replace URLs in .gitmodules!

# TODO: Commands to change submodule links?

# Init submodules
git submodule update --init --recursive

# Create real profile (gitignored)
cp conf/profiles/example/variables.nix conf/profiles/$hostname/variables.nix
# edit conf/profiles/<hostname>/variables.nix - fill real hostname, users, IPs

# Generate age key (first time)
age-keygen -o ~/.config/sops/age/keys.txt
# Add public key to conf/secrets/.sops.yaml

# 5. Create secrets
sops conf/secrets/<hostname>/secrets.yaml
# Fill: admin-password, wg-private-key, initrd-host-key (if LUKS+SSH unlock)

# 6. Add to flake.nix nixosConfigurations (two lines - see flake.nix comments)

# 7. Build
nix flake check
nixos-rebuild switch --flake .#<hostname>
```
