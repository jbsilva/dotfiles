{ pkgs, gitExtraCommandsSrc, ... }:
let
  ###########################################################################
  # unixorn/git-extra-commands
  #
  # A collection of `git-*` scripts, so each becomes a git subcommand:
  # `git delete-local-merged`, `git churn`, `git forest`, `git divergence`,
  # `git fzf-log-browser`, ...
  #
  # Not in nixpkgs, so it is pinned here. Only the scripts in bin/ are
  # installed; several call each other (git-delete-local-merged uses
  # `git origin-head`), so they are installed as a set rather than picked over.
  #
  # Complements git-extras rather than duplicating it: barely any of the two
  # command sets overlap.
  #
  # The source is the `git-extra-commands` flake input, so the rev and its hash
  # live in flake.lock: `just update` moves it with everything else, and
  # `just update-input git-extra-commands` moves it alone. Keep it out of a
  # `fetchFromGitHub` here, which would need a fixed-output hash computed by
  # hand on every bump, because Renovate cannot work one out.
  ###########################################################################
  gitExtraCommands = pkgs.stdenvNoCC.mkDerivation {
    pname = "git-extra-commands";
    # The date is in flake.lock, and this string is not worth keeping in step
    # with it by hand.
    version = "0-unstable";

    src = gitExtraCommandsSrc;

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp bin/git-* $out/bin/
      chmod +x $out/bin/*
      runHook postInstall
    '';

    meta = {
      description = "Collection of git subcommands from unixorn";
      homepage = "https://github.com/unixorn/git-extra-commands";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.unix;
    };
  };
in
{
  environment.systemPackages = [
    gitExtraCommands

    # tj/git-extras: a separate, maintained collection.
    # `git delete-merged-branches`, `git summary`, `git effort`, `git undo`.
    pkgs.git-extras
  ];
}
