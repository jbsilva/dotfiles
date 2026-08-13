{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.system.primaryUser;
  home = "/Users/${user}";

  # Homebrew 6 refuses to install casks from third-party taps unless they are in
  # the trust store (`brew trust`). Those are exactly the casks written as
  # owner/tap/name; the ones from homebrew/cask are bare names.
  #
  # nix-darwin normalises homebrew.casks into attrsets, so match on .name.
  # Deriving the list means adding a third-party cask is a one-line change
  # instead of also remembering to run `brew trust`.
  trustedCasks = map (c: c.name) (
    lib.filter (c: lib.hasInfix "/" c.name) config.homebrew.casks
  );

  trustFile = pkgs.writeText "homebrew-trust.json" (
    builtins.toJSON { trustedcasks = trustedCasks; }
  );
in
{
  ###########################################################################
  # Homebrew trust store
  #
  # Written as a REAL file, declaratively, before `brew bundle` runs.
  #
  # It used to be a tracked JSON file in .config/homebrew/ that got symlinked
  # into place. That broke once ~/.config became a real directory with per-file
  # links, because Homebrew's rules for the trust store are strict
  # (Library/Homebrew/trust.rb):
  #
  #   * the path may be a symlink, but its target must NOT itself be a symlink
  #   * the file and its directory must be owned by the calling user
  #   * neither may be group- or world-writable
  #
  # ~/.homebrew/trust.json -> ~/.config/homebrew/trust.json -> repo file was two
  # hops, so brew refused with "target is a symlink" and failed activation.
  #
  # Both locations are written because they are used in different contexts:
  # nix-darwin runs `brew bundle` via `sudo --user=julio --set-home env`, which
  # drops XDG_CONFIG_HOME, so brew falls back to ~/.homebrew/trust.json. An
  # interactive `brew trust` with XDG_CONFIG_HOME set uses the other one.
  #
  # This runs in extraActivation, which nix-darwin schedules well before the
  # Homebrew bundle step -- the ordering the previous home-manager activation
  # script got wrong, since home-manager activation runs after brew bundle.
  ###########################################################################
  system.activationScripts.extraActivation.text = lib.mkBefore ''
    echo "Writing Homebrew trust store (${toString (builtins.length trustedCasks)} trusted casks)..."

    for trustDir in "${home}/.homebrew" "${home}/.config/homebrew"; do
      mkdir -p "$trustDir"
      chown ${user} "$trustDir"
      # 0755: readable, but not group/world writable, which brew requires.
      chmod 0755 "$trustDir"

      # Replace whatever is there, including a stale symlink from an earlier
      # generation -- `install` would otherwise write through it.
      rm -f "$trustDir/trust.json"
      install -m 0600 -o ${user} "${trustFile}" "$trustDir/trust.json"
    done

    echo "Homebrew trust store written."
  '';
}
