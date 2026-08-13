{ config, ... }:
let
  # Homebrew 6 refuses to load casks/formulae from untrusted third-party taps
  # (see `brew trust`). The trust store lives at $XDG_CONFIG_HOME/homebrew, which
  # for this user resolves into the dotfiles repo, so it is tracked in git.
  #
  # nix-darwin runs `brew bundle` as `sudo --preserve-env=PATH --user=julio
  # --set-home env brew bundle`, which drops XDG_CONFIG_HOME. Brew then falls
  # back to ~/.homebrew/trust.json and, without this link, sees an empty trust
  # store and fails activation on e.g. docker/tap casks.
  #
  # A single-hop symlink is deliberate: brew resolves the link before writing, so
  # `brew trust` from either environment updates the tracked file. It refuses to
  # write through a symlink whose target is itself a symlink or lives in a
  # root-owned directory, which rules out home.file/mkOutOfStoreSymlink here.
  trustStore = "${config.home.homeDirectory}/.config/homebrew/trust.json";
in
{
  home.activation.homebrewTrustStore = ''
    echo "Linking Homebrew trust store..."

    mkdir -p "$HOME/.homebrew"
    chmod 700 "$HOME/.homebrew"
    ln -sfn "${trustStore}" "$HOME/.homebrew/trust.json"

    echo "Homebrew trust store linked to ${trustStore}"
  '';
}
