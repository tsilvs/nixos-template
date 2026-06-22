# Secrets Setup

How to create credentials for a host profile.

## Prerequisites

- `age` installed (`brew install age` or `sudo dnf install age`)
- `sops` installed (`brew install sops`)
- Repo cloned, `.sops.yaml` at repo root

---

## 1. Generate age keypair (once, per admin machine)

```bash
age-keygen -o ~/.config/sops/age/<profile>.keys.txt
```

Prints: `# Public key: age1...` - save this value.

---

## 2. Add pubkey to `.sops.yaml`

Edit `.sops.yaml` at repo root. Under your host's `path_regex` rule, replace the `&admin` placeholder:

```yaml
- &admin age1... # admin machine
```

The `&host_<hostname>` entry is filled after first boot (see step 6).

---

## 3. Create secrets file

```bash
SOPS_AGE_KEY_FILE=~/.config/sops/age/<profile>.keys.txt sops conf/secrets/<hostname>/secrets.yaml
```

Editor opens. Define secrets:

```yaml
admin-password: yourpasswordhere
```

Save and quit - sops encrypts on exit.

---

## 4. Generate SSH keypair

```bash
ssh-keygen -t ed25519 -f ~/.ssh/<hostname> -C "admin@<hostname>"
```

---

## 5. Edit `variables.nix`

```
conf/profiles/<hostname>/variables.nix
```

Set:

```nix
users = [
  {
    name         = "admin";
    passwordFile = "/run/secrets/admin-password";
    pubkeys      = [ "<contents of ~/.ssh/<hostname>.pub>" ];
    # ...
  }
];
```

---

## 6. After first boot - add host SSH key

```bash
ssh-keyscan <host-ip> | ssh-to-age
```

Paste the resulting `age1...` into `.sops.yaml` under `&host_<hostname>`, then re-encrypt:

```bash
SOPS_AGE_KEY_FILE=~/.config/sops/age/<profile>.keys.txt sops updatekeys conf/secrets/<hostname>/secrets.yaml
```

---

## Login after deploy

```bash
ssh -i ~/.ssh/<hostname> admin@<host-ip>
```

Password (unix/TTY fallback): value set in `admin-password` secret.
