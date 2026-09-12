{ config, lib, ... }:
let
  sopsFile = ../../secrets/secrets.yaml;

  # Inert until the encrypted file exists, so a fresh clone evaluates before
  # anyone has run `age-keygen`. Note that a flake only sees files git tracks:
  # after `sops secrets/secrets.yaml` creates it, `git add secrets/secrets.yaml`
  # is what makes this true.
  haveSecrets = builtins.pathExists sopsFile;
in
lib.mkIf haveSecrets {
  ###########################################################################
  # Secrets, through sops-nix.
  #
  # This repository is public, so anything private has to be encrypted before
  # it is committed. sops encrypts the *values* in a YAML file and leaves the
  # keys readable, so a diff still shows which secret changed and a merge
  # conflict is still a conflict in one value rather than in one opaque blob.
  #
  # age rather than GPG for the key. The GPG key here is on a YubiKey and
  # signs commits; decryption at activation must not need a touch, or every
  # `just switch` stops and waits for one.
  #
  # The flow, once:
  #
  #   age-keygen -o ~/Library/Application\ Support/sops/age/keys.txt
  #   # put the PUBLIC key it prints into ../../.sops.yaml
  #   sops ../../secrets/secrets.yaml        # opens $EDITOR on the plaintext
  #
  # Back the private key up somewhere that is not this repository. It is the
  # only thing that can read any of this, and losing it loses every secret.
  #
  # `sops-nix` decrypts to files under /run at activation and points the
  # consumers at those paths. Nothing decrypted is ever written into the repo.
  ###########################################################################
  sops = {
    defaultSopsFile = sopsFile;
    # The file holds ordinary YAML keys, not a flat dotted namespace.
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.users.users.julio.home}/Library/Application Support/sops/age/keys.txt";

    secrets = {
      # ~/.ssh/config. It names internal hosts, jump hosts, ports and key
      # paths, which is exactly the map of a private network, and this
      # repository is public. The `nas` and `nast` Host blocks in it are
      # load-bearing: `just nas-switch` SSHes to them, and typos.toml
      # documents `nast` as the Tailscale one.
      #
      # Mode 600 and owned by julio, because ssh refuses to read a config
      # that is group- or world-writable and silently ignores one it does not
      # own.
      "ssh_config" = {
        owner = "julio";
        mode = "0600";
        path = "${config.users.users.julio.home}/.ssh/config";
      };
    };
  };
}
