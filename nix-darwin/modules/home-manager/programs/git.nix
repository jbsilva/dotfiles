{ pkgs, config, lib, ... }:
{
  programs.git = {
    enable = true;
    signing = {
      key = "3E596BF69EFC73E6";
      signByDefault = true;
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
        snap = "!git stash save \"snapshot: $(date)\"";
        unstash = "stash pop";
        rmbranch = "!f(){ git branch -d \${1} && git push origin --delete \${1}; };f";
        mkbranch = "!f(){ git checkout -b \${1} && git push origin -u \${1}; };f";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        ld = "log --pretty=format:\"%h | Committer: %ci | Author: %ai | %an <%ae> | %s%d\"";
        aliases = "config --get-regexp alias";
        shove = "push --force-with-lease";
        unpushed = "cherry -v --abbrev";
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
      };

      column.ui = "auto";
      branch.sort = "-committerdate";

      tag = {
        sort = "version:refname";
        gpgSign = true;
      };

      merge = {
        conflictstyle = "zdiff3";
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
      gpg.program = "${pkgs.gnupg}/bin/gpg";

      gitbutler = {
        aiModelProvider = "lmstudio";
        aiLMStudioModelName = "default";
        aiLMStudioEndpoint = "http://127.0.0.1:1234";
        gitbutlerCommitter = "0";
      };
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
