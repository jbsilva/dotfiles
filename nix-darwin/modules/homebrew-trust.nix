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
  trustedCasks = map (c: c.name) (lib.filter (c: lib.hasInfix "/" c.name) config.homebrew.casks);

  trustFile = pkgs.writeText "homebrew-trust.json" (builtins.toJSON { trustedcasks = trustedCasks; });
in
{
  ###########################################################################
  # Homebrew trust store
  #
  # Homebrew validates this file strictly (Library/Homebrew/trust.rb):
  #
  #   * the path may be a symlink, but its target must not itself be a symlink
  #   * the file and its directory must be owned by the calling user
  #   * neither may be group- or world-writable
  #
  # So it is written as a plain file rather than linked in from the repo.
  #
  # Both locations are written because brew picks between them by environment:
  # nix-darwin runs `brew bundle` through `sudo --user=julio --set-home env`,
  # which drops XDG_CONFIG_HOME and sends brew to ~/.homebrew/trust.json, while
  # an interactive `brew trust` uses the XDG path.
  #
  # extraActivation runs before the Homebrew step; home-manager activation runs
  # after it, so this cannot live there.
  ###########################################################################
  system.activationScripts.extraActivation.text = lib.mkBefore ''
    echo "Writing Homebrew trust store (${toString (builtins.length trustedCasks)} trusted casks)..."

    for trustDir in "${home}/.homebrew" "${home}/.config/homebrew"; do
      mkdir -p "$trustDir"
      chown ${user} "$trustDir"
      # 0755: readable, but not group/world writable, which brew requires.
      chmod 0755 "$trustDir"

      # Remove first: `install` would write through an existing symlink.
      rm -f "$trustDir/trust.json"
      install -m 0600 -o ${user} "${trustFile}" "$trustDir/trust.json"
    done

    echo "Homebrew trust store written."
  '';
}
