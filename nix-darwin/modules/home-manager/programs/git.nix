{
  config,
  lib,
  pkgs,
  ...
}:
{
  ###########################################################################
  # delta: syntax-highlighted diffs for terminal git.
  #
  # delta has been in packages.nix for a while but nothing ever pointed git at
  # it, so `git diff` was still plain. enableGitIntegration sets core.pager and
  # the interactive.diffFilter, which is what actually makes it apply.
  #
  # Complementary to Fork, not competing with it: Fork is for browsing history
  # and staging, this is for `git diff` and `git show` in the terminal.
  ###########################################################################
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true; # n / N jump between files, as in less
      line-numbers = true;
      hyperlinks = true; # file:line links Ghostty can open
      syntax-theme = "TwoDark"; # close to the nvim tokyonight-night palette
    };
  };

  programs.git = {
    enable = true;
    signing = {
      key = "D1C6B63BEAE5330F";
      signByDefault = true;
      # Do NOT set format = "openpgp" here. It's git's default, but setting it
      # causes home-manager to emit [gpg "openpgp"] program = <package>/bin/gpg,
      # which overrides our gpg.program below with the dummy nix package path.
    };

    #########################################################################
    # Global ignores.
    #
    # The OS-junk half is read from .gitignore-global rather than restated
    # here, because that file is already `core.excludesfile` on the Linux, WSL
    # and Windows machines. Kept as two lists they drifted: this one had grown
    # node_modules/ and __pycache__/, that one .fuse_hidden*, $RECYCLE.BIN/ and
    # *.lnk, and neither machine got both.
    #
    # home-manager joins these with newlines into ~/.config/git/ignore, and git
    # reads that as an ignore file, so the comments and blank lines in the
    # imported text are fine as-is.
    #########################################################################
    ignores = lib.splitString "\n" (builtins.readFile ../../../../.gitignore-global) ++ [
      # Editor and tooling noise, on top of the OS junk imported above.
      ".idea/"
      "*.swp"
      "*.swo"
      ".vim/backup/"
      ".vim/swap/"
      ".vim/undo/"
      "node_modules/"
      "__pycache__/"
      "*.pyc"
      ".pytest_cache/"
      ".direnv/"
      ".envrc"
      "*.tmp"
      "*.temp"
      ".cache/"
      # Never commit these by accident, wherever they turn up.
      ".env"
      ".env.local"
      "*.pem"
      "*.key"
    ];

    settings = {
      user = {
        name = "Julio Batista Silva";
        email = "julio@juliobs.com";
      };

      core = {
        editor = "nvim";
        autocrlf = false;
        safecrlf = "warn";
      };

      pull.rebase = true;
      init.defaultBranch = "main";

      push = {
        autoSetupRemote = true;
        default = "simple";
        followTags = true;
      };

      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };

      column.ui = "auto";
      branch.sort = "-committerdate";

      tag = {
        sort = "version:refname";
        gpgSign = true;
      };

      merge = {
        conflictstyle = "zdiff3";
        # nvim rather than meld: meld was a cask that is no longer installed,
        # and nvim is already the editor, so it is always there.
        tool = "nvimdiff";
      };

      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };

      help.autocorrect = "prompt";
      commit.verbose = true;

      # The Synology has no secret service, so no keyring helper exists to point
      # at there. `cache` keeps the token in a daemon's memory for an hour
      # instead of writing it to disk, which is what `store` would do.
      credential.helper =
        if pkgs.stdenv.hostPlatform.isDarwin then "osxkeychain" else "cache --timeout 3600";
      gpg.program = if pkgs.stdenv.hostPlatform.isDarwin then "/opt/homebrew/bin/gpg" else "gpg";
    };

    #########################################################################
    # Includes.
    #
    # git/aliases holds the alias list for every machine, this one included.
    # Keep aliases there rather than in a `settings.alias` block here: a set
    # defined here reaches only the machines home-manager configures, and the
    # same names then have to be maintained a second time in .gitconfig-global
    # for the ones it does not. `ignores` above is shared for the same reason.
    #
    # An include of a live path rather than `builtins.readFile` into
    # `settings.alias`. readFile would work and would even be purer, but it
    # bakes the list into a store path, so adding an alias would need a
    # `just switch` before it answered. This way editing git/aliases takes
    # effect at the next `git` invocation, on every machine alike.
    #
    # One plain list, not two definitions: git applies includes in the order it
    # reads them, and a list literal keeps that order. `lib.mkAfter` would order
    # this definition against other definitions of the same option, which is a
    # different question and not the one that matters here. The Hoppe entry goes
    # last so a repository under ~/Dev/Hoppe can override anything above it.
    #########################################################################
    includes = [
      { path = "${config.home.homeDirectory}/dotfiles/git/aliases"; }
      {
        # Equivalent to: [includeIf "gitdir:~/Dev/Hoppe/**"]
        condition = "gitdir:${config.home.homeDirectory}/Dev/Hoppe/**";
        path = "${config.home.homeDirectory}/Dev/Hoppe/.gitconfig";
      }
    ];
  };
}
