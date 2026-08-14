{ pkgs, ... }:
let
  ###########################################################################
  # unixorn/git-extra-commands
  #
  # A collection of `git-*` scripts, so each becomes a git subcommand:
  # `git delete-local-merged`, `git churn`, `git forest`, `git divergence`,
  # `git fzf-log-browser`, ...
  #
  # Not in nixpkgs, so it is pinned here by revision. Only the scripts in bin/
  # are installed; several call each other (git-delete-local-merged uses
  # `git origin-head`), so they are installed as a set rather than picked over.
  #
  # Complements git-extras rather than duplicating it: of 162 commands here and
  # 78 there, 5 overlap.
  ###########################################################################
  gitExtraCommands = pkgs.stdenvNoCC.mkDerivation {
    pname = "git-extra-commands";
    version = "0-unstable-2026-08-14";

    src = pkgs.fetchFromGitHub {
      owner = "unixorn";
      repo = "git-extra-commands";
      rev = "6a83b7eb388812f5c42f22d7363a4ff77735face";
      hash = "sha256-qHveMIMJcKISSLpgllQ9VhwsSV2dTjvpXzC62xiD5Pw=";
    };

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
