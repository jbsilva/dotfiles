# secrets

Encrypted with [sops] and an [age] key, decrypted at activation by [sops-nix].

This repository is public. Everything here is safe to commit **because it is encrypted**, not
because it is harmless. `secrets.yaml` is the only file, and sops encrypts its values and leaves its
keys readable, so a diff still shows which secret changed.

The wiring is in [`nix-darwin/modules/secrets.nix`](../nix-darwin/modules/secrets.nix), and which
key a file is encrypted to is in [`.sops.yaml`](../.sops.yaml).

## First-time setup

Run these once, on the MacBook. Nothing works until the key exists.

1. Make the key pair. Keep the private half out of this repo.

   ```sh
   mkdir -p ~/Library/Application\ Support/sops/age
   age-keygen -o ~/Library/Application\ Support/sops/age/keys.txt
   ```

2. Copy the `age1...` public key it prints into `keys:` in `.sops.yaml`, replacing
   `age1PUT_THE_PUBLIC_KEY_HERE`.

3. Back the private key up somewhere that is not this repository, and is not the same disk. It is
   the only thing that can read any of this.

4. Create the file and put the first secret in it:

   ```sh
   sops secrets/secrets.yaml
   ```

   `sops` opens `$EDITOR` on the decrypted text and encrypts what you save. Give it this shape:

   ```yaml
   ssh_config: |
     Host nas
       HostName ...
   ```

   The `|` matters: it makes the whole SSH config one string value, so sops encrypts it as one blob
   and the file lands byte for byte.

5. `just switch`. sops-nix writes `~/.ssh/config`, mode 600.

## Moving ~/.ssh/config in

The file already on disk is the source. This reads it into the right key without it ever passing
through a shell history:

```sh
# From the repo root, with .sops.yaml filled in.
{ printf 'ssh_config: |\n'; sed 's/^/  /' ~/.ssh/config; } > /tmp/ssh.yaml
sops --encrypt /tmp/ssh.yaml > secrets/secrets.yaml
rm /tmp/ssh.yaml
```

Then check it round-trips **before** letting activation overwrite the original:

```sh
sops --decrypt secrets/secrets.yaml | yq -r .ssh_config | diff - ~/.ssh/config \
  && echo "identical"
```

`just switch` replaces `~/.ssh/config` with a link to the decrypted copy under `/run`.
home-manager's `backupFileExtension` does not apply to sops-nix, so move the original aside yourself
first if you want a copy:

```sh
cp ~/.ssh/config ~/.ssh/config.pre-sops
```

## Adding a secret

1. `sops secrets/secrets.yaml`, add a key.
2. Add a matching entry to `sops.secrets` in `nix-darwin/modules/secrets.nix`, with the `path`,
   `owner` and `mode` the consumer needs.
3. `just switch`.

## Adding a machine

Each machine gets its own key pair, never a copy of this one.

1. `age-keygen` on that machine, as in step 1 above.
2. Add its public key to `keys:` and to the `key_groups` list in `.sops.yaml`.
3. `sops updatekeys secrets/secrets.yaml`, which re-encrypts to every recipient listed. Without this
   step the new machine cannot read the existing values.

## Traps

**Editing `.sops.yaml` does not re-encrypt anything.** It only decides what a *future* encryption
does. Run `sops updatekeys` after every change to `keys:`.

**Do not `git add` a decrypted file.** There is no plaintext file to add if the flow above is
followed: `sops` never writes one. `just scan` runs gitleaks over the whole history and is the
backstop.

**The age key is not the GPG key.** The GPG key on the YubiKey signs commits. Decryption at
activation has to be unattended, and a YubiKey touch is not.

[age]: https://github.com/FiloSottile/age
[sops]: https://github.com/getsops/sops
[sops-nix]: https://github.com/Mic92/sops-nix
