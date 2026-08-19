{ pkgs, lib, ... }:
let
  ###########################################################################
  # Plugins, sourced straight out of /nix/store.
  #
  # `programs.zsh.plugins` is avoided on purpose: it materialises each plugin
  # under ~/.zsh/plugins via home.file, and ~/.zsh is a symlink into this repo,
  # so that would write generated store symlinks into the working tree.
  #
  # mkOrder 900 puts these after home-manager's own syntax-highlighting block
  # and before .zshrc at 1000. zsh-autopair requires that ordering.
  ###########################################################################
  pluginFiles = [
    # Warns when an alias exists for the command just typed.
    "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"
    # Off while Atuin owns Ctrl-R: the widget would be sourced and never bound.
    # "${pkgs.zsh-history-search-multi-word}/share/zsh/zsh-history-search-multi-word/history-search-multi-word.plugin.zsh"
    # Auto-closes quotes and brackets.
    "${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh"
  ];

  sourcePlugins = ''
    # Zsh plugins, pinned by flake.lock and sourced from the Nix store.
    ${lib.concatMapStringsSep "\n" (f: "source ${f}") pluginFiles}
  '';

  ###########################################################################
  # Syntax highlighting: zsh-patina rather than zsh-syntax-highlighting.
  #
  # z-sy-h costs 66 ms to source in every shell, measured by A/B'ing the
  # generated .zshrc with hyperfine -- the largest single item left in startup
  # after the completion caching. patina does the highlighting in a Rust daemon
  # instead, so the shell side is small, and it is also faster per keystroke
  # (its published benchmark: 0.197 ms vs 0.528 ms for z-sy-h).
  #
  # It attaches through add-zle-hook-widget on zle-line-pre-redraw rather than
  # by wrapping widgets, so it does not care where it sits relative to
  # autosuggestions, autopair or fzf-tab. Loaded last anyway, out of caution.
  #
  # `activate` is eval'd rather than cached: the generated snippet bakes in a
  # $TMPDIR socket path, and upstream explicitly says not to cache it. It costs
  # ~3 ms.
  #
  # Only the Nix machines get this. .zshrc still looks for the distro's
  # zsh-syntax-highlighting everywhere else.
  ###########################################################################
  patinaInit = ''
    if [[ -x ${pkgs.zsh-patina}/bin/zsh-patina ]]; then
      eval "$(${pkgs.zsh-patina}/bin/zsh-patina activate)"
    fi
  '';
in
{
  ###########################################################################
  # Zsh
  #
  # ~/.zshrc is shared with the Linux, WSL and Synology machines, which have no
  # Nix, so it stays self-contained: history, options, aliases and keybindings
  # all live there. This module only supplies the plugins, and signals that via
  # DOTFILES_PLUGINS_FROM_NIX so .zshrc knows not to look for system ones.
  ###########################################################################
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # home-manager sources these in the order they require: syntax
    # highlighting last, substring search after it.
    autosuggestion.enable = true;
    # Off: zsh-patina replaces it, wired up in initContent below.
    syntaxHighlighting.enable = false;
    historySubstringSearch.enable = true;

    defaultKeymap = "viins";

    # Only extend fpath: the default here runs a second, uncached `compinit`,
    # and .zshrc already runs one with a daily cache and zcompile.
    completionInit = ''
      fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
    '';

    # ~/.zshenv, sourced before ~/.zshrc, so .zshrc can skip its own
    # plugin lookup.
    #
    # fzf-tab is passed as a path rather than sourced with the others: it has to
    # load after compinit, which runs inside .zshrc, so .zshrc sources it there.
    #
    # .zshenv is appended for the same reason .zshrc feeds initContent: the
    # non-Nix machines symlink it, so it stays a plain file.
    envExtra = ''
      export DOTFILES_PLUGINS_FROM_NIX=1
      export DOTFILES_FZF_TAB=${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      export DOTFILES_OMZ=${pkgs.oh-my-zsh}/share/oh-my-zsh
    ''
    + builtins.readFile ../../../../.zshenv;

    initContent = lib.mkMerge [
      (lib.mkOrder 900 sourcePlugins)
      (lib.mkOrder 1000 (builtins.readFile ../../../../.zshrc))
      (lib.mkOrder 1500 patinaInit)
    ];
  };
}
