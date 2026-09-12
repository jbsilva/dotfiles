###############################################################################
# Arch on the desktop, and Ubuntu under WSL on the work machine.
#
# Standalone home-manager, as on the Synology: these run neither NixOS nor
# nix-darwin, so there is no system configuration to hang this off. They share
# this flake, and so flake.lock, with the MacBook.
#
# One module for both. They are ordinary x86_64 Linux with Nix installed, and
# .zshrc already tells them apart at runtime through $DOTFILES_PLATFORM, which
# is what picks .zsh/zshrc_wsl over the plain Linux file. Split this into two
# when they actually need to differ.
#
# home-manager writes ~/.zshrc, ~/.zshenv and the ~/.config links here, so
# bringing up one of these machines is `nix run home-manager -- switch` and no
# symlinking by hand. The `ln -s` list under "New machine" in the README is for
# a machine with no Nix at all.
#
# programs/git.nix comes with it, which is the point: git/aliases reaches every
# machine this way, rather than only the ones that read .gitconfig-global.
#
# What it does NOT do is install a desktop. Arch keeps its own packages under
# pacman, and this only adds the shell and the tools that .zshrc looks for.
###############################################################################
{ config, pkgs, ... }:
{
  imports = [
    ./programs/zsh.nix
    ./programs/git.nix
    ./programs/atuin.nix
    ./programs/direnv.nix
    ./programs/zellij.nix
  ];

  home.username = "julio";
  home.homeDirectory = "/home/julio";
  home.stateVersion = "26.05";

  # Same reasoning as xdg.nix on macOS: link out of the repo rather than into
  # the store, so editing a config takes effect without a rebuild, and link
  # whole directories only where the directory is entirely ours.
  #
  # Linux-only XDG files stay in linux/config/ and are linked by hand. They
  # cannot live in .config/, which is shared with macOS. See the Layout section
  # of the README.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/nvim";

  home.packages = with pkgs; [
    # -------------------------------------------------------------------------
    # Shell
    #
    # The set .zshrc reaches for by name. Everything here is guarded there with
    # `(( $+commands[...] ))`, so a missing one degrades rather than breaks, but
    # these are the ones worth having the same version of on every machine.
    # -------------------------------------------------------------------------
    atuin # shell history in SQLite, behind Ctrl-R
    bat # cat with syntax highlighting; fzf previews with it
    eza # ls with git status and tree mode; backs the k/kk aliases
    fd # feeds FZF_DEFAULT_COMMAND
    fzf # fuzzy finder
    just # task runner; the Justfile at the repo root
    ripgrep # fast grep
    starship # prompt
    vivid # generates LS_COLORS; .zshrc prefers it over dircolors
    zoxide # directory jumper, behind `z`

    # The plugins .zshrc would otherwise hunt for under /usr/share. With these
    # present, programs/zsh.nix sets $DOTFILES_PLUGINS_FROM_NIX and the search
    # is skipped, so the pacman and apt copies can go.
    #
    # Listed here rather than in programs/zsh.nix because that module sources
    # them from the store by path; these are for anything that looks them up.
    zsh-completions

    # -------------------------------------------------------------------------
    # Git
    # -------------------------------------------------------------------------
    git # programs/git.nix configures it; this provides the binary
    delta # syntax-highlighted diffs; git.nix points core.pager at it
    git-absorb # routes fixups into the right commit during rebase

    # -------------------------------------------------------------------------
    # Editing and terminal
    # -------------------------------------------------------------------------
    neovim # config in .config/nvim, linked above
    tree-sitter # nvim-treesitter's `main` branch builds parsers with it
    zellij # multiplexer; .zshrc auto-attaches on SSH

    # -------------------------------------------------------------------------
    # Data
    # -------------------------------------------------------------------------
    jq # JSON processor
    yq-go # the same for YAML/XML/TOML
  ];
}
