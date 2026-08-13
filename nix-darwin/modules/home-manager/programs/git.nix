{
  config,
  lib,
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

    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "Icon?"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"
      ".vim/backup/"
      ".vim/swap/"
      ".vim/undo/"
      "node_modules/"
      "__pycache__/"
      "*.pyc"
      ".pytest_cache/"
      ".direnv/"
      ".envrc"
      "Thumbs.db"
      "Desktop.ini"
      ".directory"
      "*.tmp"
      "*.temp"
      ".cache/"
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

      alias = {
        co = "checkout";
        ci = "commit";
        st = "status -s";
        br = "branch";
        cp = "cherry-pick";
        amend = "commit --amend";
        commit-each = "!git diff --name-only -z | xargs -0 -I {} sh -c 'git add -- \"$1\" && git commit -m \"$1\" -- \"$1\"' _ {}";
        commit-each-staged = "!git diff --cached --name-only -z | xargs -0 -I {} sh -c 'git commit -m \"$1\" -- \"$1\"' _ {}";
        snap = "!git stash save \"snapshot: $(date)\"";
        unstash = "stash pop";
        mkbranch = "!f(){ git checkout -b \${1} && git push origin -u \${1}; };f";
        rmbranch = "!f(){ git branch -d \${1} && git push origin --delete \${1}; };f";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        logg = "log --pretty=format:\"%h | %G? | CD: %ci | AD: %ai | %an <%ae> | %s%d\"";
        ld = "log --pretty=format:\"%h | %G? | Committer: %ci | Author: %ai | %an <%ae> | %s%d\"";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        aliases = "config --get-regexp alias";
        shove = "push --force-with-lease";
        unpushed = "cherry -v --abbrev";

        # Inspection
        type = "cat-file -t";
        dump = "cat-file -p";
        whatis = "show -s --pretty='tformat:%h (%s, %ad)' --date=short";
        # Find the commit that first introduced a file (follows renames)
        whatadded = "log --follow --diff-filter=A --find-renames=40%";
        contains = "branch --contains";
        cloneurl = "config --get remote.origin.url";
        ls-ignored = "ls-files --exclude-standard --ignored --others";
        show-tree = "log --all --graph --decorate --oneline --simplify-by-decoration";
        lc = "log ORIG_HEAD.. --stat --no-merges";
        # Commits created by the last command that moved this ref
        new = "!sh -c 'git log $1@{1}..$1@{0} \"$@\"'";
        # Branches already merged into the current branch
        lurkers = "branch --merged";

        # Conflict resolution
        accept-ours = "!f() { git checkout --ours -- \"\${@:-.}\"; git add -u \"\${@:-.}\"; }; f";
        accept-theirs = "!f() { git checkout --theirs -- \"\${@:-.}\"; git add -u \"\${@:-.}\"; }; f";

        # Stash helpers
        snapshot = "!git stash save \"snapshot: $(date)\" && git stash apply \"stash@{0}\"";
        snapshots = "!git stash list --grep snapshot";
        # Show the full diff of every stash entry
        sll = "!f() { for s in $(git stash list --pretty=format:%gd); do git stash show -p $s; done; };f";

        # Discard file-mode-only changes
        permission-reset = "!git diff -p -R --no-ext-diff --no-color | grep -E \"^(diff|(old|new) mode)\" --color=never | git apply";

        # Interactive `git clean -df`
        cl = "!f() { echo 'Remove following files?'; echo; git clean -dn; echo; echo 'Press ENTER to confirm'; read -p 'Press ^C to stop cleanup and exit' a && git clean -df; }; f";

        prune-all = "!git remote | xargs -n 1 git remote prune";
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
      credential.helper = "osxkeychain";
      gpg.program = "/opt/homebrew/bin/gpg";
    };

    # Conditional includes for per-directory Git config.
    # Use mkAfter to ensure this include appears at the end of config so it can override values.
    includes = lib.mkAfter [
      {
        # Equivalent to: [includeIf "gitdir:~/Dev/Hoppe/**"]
        condition = "gitdir:${config.home.homeDirectory}/Dev/Hoppe/**";
        path = "${config.home.homeDirectory}/Dev/Hoppe/.gitconfig";
      }
    ];
  };
}
