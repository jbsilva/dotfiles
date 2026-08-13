{ pkgs, lib, ... }:
let
  ###########################################################################
  # Plugins are sourced straight out of /nix/store.
  #
  # home-manager's `programs.zsh.plugins` option is deliberately NOT used: it
  # materialises each plugin under ~/.zsh/plugins via home.file, and ~/.zsh is a
  # symlink to ~/dotfiles/.zsh, so that would write generated store symlinks
  # into the git repo. Sourcing the store paths directly avoids touching the
  # filesystem at all.
  #
  # Loaded after home-manager's own autosuggestion/syntax-highlighting block
  # (mkOrder 900 < the 1000 that .zshrc gets, but after HM's plugin section).
  # zsh-autopair documents that it must come after zsh-syntax-highlighting,
  # which this ordering satisfies.
  ###########################################################################
  pluginFiles = [
    # Replaces djui/alias-tips: reminds you an alias exists for what you typed.
    "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"
    # Was zdharma-continuum/history-search-multi-word; provides the
    # history-search-multi-word widget that .zshrc binds to Ctrl-R.
    "${pkgs.zsh-history-search-multi-word}/share/zsh/zsh-history-search-multi-word/history-search-multi-word.plugin.zsh"
    # Was hlissner/zsh-autopair.
    "${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh"
  ];

  sourcePlugins = ''
    # Zsh plugins, pinned by flake.lock and sourced from the Nix store.
    ${lib.concatMapStringsSep "\n" (f: "source ${f}") pluginFiles}
  '';
in
{
  ###########################################################################
  # Zsh
  #
  # Plugins used to be managed by zplug, which bootstrapped itself by running
  # `git clone` from inside ~/.zshrc: every shell start could hit the network,
  # nothing was pinned, and zplug has been unmaintained since 2020. Prezto sat
  # on top of that as a second framework.
  #
  # IMPORTANT: ~/.zshrc is shared with the Linux and WSL machines, which have no
  # Nix. It therefore stays self-contained (history, options, aliases,
  # keybindings) and still falls back to zplug when DOTFILES_PLUGINS_FROM_NIX is
  # unset. Only plugin *management* moved here.
  ###########################################################################
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # These three were Prezto modules. home-manager knows they have to be
    # sourced in a specific order (syntax highlighting last, substring search
    # after it), which is easy to get wrong by hand.
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    # Replaces Prezto's `editor` module with key-bindings 'vi'.
    defaultKeymap = "viins";

    # Only extend fpath here. home-manager's default completionInit would run a
    # second, uncached `compinit`; .zshrc already runs one with a daily cache
    # and zcompile, which is the expensive step worth doing exactly once.
    completionInit = ''
      fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
    '';

    # ~/.zshenv, sourced before ~/.zshrc in every shell. The flag tells .zshrc
    # that plugins are already provided, so it can skip the zplug bootstrap.
    envExtra = ''
      export DOTFILES_PLUGINS_FROM_NIX=1
    '';

    initContent = lib.mkMerge [
      (lib.mkOrder 900 sourcePlugins)
      (lib.mkOrder 1000 (builtins.readFile ../../../../.zshrc))
    ];
  };
}
