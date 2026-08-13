{ pkgs, lib, ... }:
{
  ###########################################################################
  # Bash
  #
  # zsh is the interactive shell. This exists because bash is unavoidable: it
  # is what `docker exec`, `sh -c`, CI images, install scripts and most remote
  # boxes drop you into, and macOS still ships bash 3.2.57 from 2007 (Apple
  # froze it at the last GPLv2 release), which has none of the niceties.
  #
  # `bash` from nixpkgs is in packages.nix, so /run/current-system/sw/bin/bash
  # is 5.x and comes first on $PATH. /bin/bash stays untouched.
  ###########################################################################
  programs.bash = {
    enable = true;
    enableCompletion = true;

    # HISTSIZE is the in-memory list, HISTFILESIZE the file. Unlike zsh's
    # SAVEHIST, the file may hold more than memory, so it is set larger.
    historySize = 10000;
    historyFileSize = 100000;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];

    shellOptions = [
      "histappend" # merge sessions instead of the last one winning
      "checkwinsize" # keep $LINES/$COLUMNS right after a resize
      "extglob"
      "globstar" # ** recurses, as it does in zsh
      "cdspell" # fix small typos in `cd` arguments
      "checkjobs" # warn about running jobs before exiting
    ];

    # Deliberately a small set: the ~100 aliases in .zshrc are full of zsh-only
    # syntax (glob qualifiers, `noglob`, ${(s.:.)}). These are the ones worth
    # having in a shell you land in rather than live in.
    shellAliases = {
      ll = "ls -lF";
      la = "ls -AF";
      lah = "ls -alh";
      ".." = "cd ../";
      "..." = "cd ../../";
      gst = "git status";
      k = "eza --long --header --group-directories-first --git";
      cat = "bat --paging=never";
    };

    #########################################################################
    # ble.sh -- Bash Line Editor
    #
    # Replaces GNU Readline outright and brings bash up to roughly zsh+plugins:
    # syntax highlighting, autosuggestions, vim mode, menu completion.
    #
    # Loading is deliberately split in two, which is what upstream documents.
    # bashrcExtra lands before home-manager's `[[ $- == *i* ]] || return`, and
    # initExtra lands after everything else, including every prompt and hook
    # set up below:
    #
    #   source ble.sh --noattach   as early as possible
    #   ble-attach                 as late as possible
    #
    # Attaching last matters. atuin drives bash through bash-preexec, and
    # ble.sh provides its own preexec/precmd; attaching before atuin has
    # installed its hooks is the documented way to end up with neither working.
    #########################################################################
    bashrcExtra = ''
      # ble.sh must be sourced before anything else touches the line editor,
      # and only for interactive shells. --noattach defers taking over until
      # ble-attach at the very end of ~/.bashrc.
      if [[ $- == *i* && -r ${pkgs.blesh}/share/blesh/ble.sh ]]; then
        source ${pkgs.blesh}/share/blesh/ble.sh --noattach
      fi
    '';

    initExtra = lib.mkMerge [
      # atuin and direnv reach bash on their own, because home-manager has
      # modules for them and those modules write into programs.bash.initExtra.
      # starship, zoxide and fzf do not: they are initialised by hand in
      # .zshrc, which bash never reads, so without this bash had no prompt, no
      # `z`, and no Ctrl-R/Ctrl-T bindings.
      #
      # Guarded on presence rather than hardcoded store paths: starship comes
      # from Homebrew here, zoxide and fzf from nixpkgs.
      ''
        if command -v starship >/dev/null 2>&1; then
          eval "$(starship init bash)"
        fi

        if command -v zoxide >/dev/null 2>&1; then
          eval "$(zoxide init bash)"
        fi

        # Since fzf 0.48 the shell integration is emitted by `fzf --bash`.
        if command -v fzf >/dev/null 2>&1; then
          eval "$(fzf --bash)"
        fi
      ''

      # mkOrder 2000, not mkAfter: direnv's module also uses mkAfter (order
      # 1500) for its `direnv hook bash`, and between two mkAfter blocks the
      # winner is just definition order. ble-attach has to run after every
      # PROMPT_COMMAND manipulation -- starship's included -- so it needs a
      # strictly higher order than all of them.
      (lib.mkOrder 2000 ''
        if [[ -n ''${BLE_VERSION-} ]]; then
          # Match the zsh setup: vi keys. `default_keymap` is the real option
          # name; ble.sh turns it into `set -o vi` internally.
          bleopt default_keymap=vi
          # Show the suggestion as dimmed text ahead of the cursor, like
          # zsh-autosuggestions does.
          bleopt complete_auto_complete=1
          bleopt complete_auto_delay=100
          # Do not beep on every ambiguous completion.
          bleopt edit_abell=
          bleopt edit_vbell=

          ble-attach
        fi
      '')
    ];
  };
}
