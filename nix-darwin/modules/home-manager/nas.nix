###############################################################################
# Synology RS2423+ (x86_64-linux)
#
# Standalone home-manager: the box runs single-user Nix, with neither NixOS nor
# nix-darwin. Its store is a bind mount from a volume. See the Synology section
# of the README. Shares this flake, and so flake.lock, with the MacBook.
#
# programs/zsh.nix is imported unchanged. Nix path literals resolve relative to
# the file they appear in, so its `../../../../.zshrc` reaches the repo root
# from here as well. The NAS gets the same generated ~/.zshrc as macOS,
# including $DOTFILES_PLUGINS_FROM_NIX, so .zshrc takes its plugins from here
# rather than searching the system for them.
###############################################################################
{ pkgs, ... }:
{
  imports = [
    ./programs/zsh.nix
    ./programs/git.nix
    ./programs/atuin.nix
    ./programs/direnv.nix
  ];

  home.username = "julio";
  home.homeDirectory = "/var/services/homes/julio";
  home.stateVersion = "26.05";

  # zshrc_synology puts the Nix profile ahead of Entware and SynoCommunity, and
  # behind ~/bin, so anything here outranks a packaged copy of the same name.
  home.packages = with pkgs; [
    # -------------------------------------------------------------------------
    # Shell
    # -------------------------------------------------------------------------
    ack # Perl-based grep-alike
    atuin # shell history in SQLite, behind Ctrl-R
    bat # cat with syntax highlighting and paging
    eza # ls with git status, tree mode and icons
    fd # far friendlier and faster `find`
    fzf # fuzzy finder; .zshrc feeds it fd and previews with bat
    ripgrep # fast grep
    starship # prompt; .zshrc initialises it, as on the other machines
    zoxide # directory jumper, behind `z`

    # -------------------------------------------------------------------------
    # Git
    # -------------------------------------------------------------------------
    git # programs/git.nix configures it; this provides the binary
    delta # syntax-highlighted git diffs
    difftastic # diffs by syntax tree rather than by line

    # -------------------------------------------------------------------------
    # Editing and terminal
    # -------------------------------------------------------------------------
    # ncurses carries share/terminfo/g/ghostty as well, so one has to win the
    # collision. Only this one has x/xterm-ghostty, which is what Ghostty sends.
    (lib.hiPrio ghostty.terminfo) # xterm-ghostty
    ncurses # tic and infocmp
    neovim # config in .config/nvim
    zellij # multiplexer; .zshrc auto-attaches to it on SSH

    # -------------------------------------------------------------------------
    # Storage and transfer
    # -------------------------------------------------------------------------
    rclone # syncs to and from cloud storage
    restic # deduplicating backups
    pv # throughput meter for a pipe
    progress # reports how far a running cp, tar or dd has got

    # -------------------------------------------------------------------------
    # Files and archives
    # -------------------------------------------------------------------------
    p7zip # 7z archives
    renameutils # qmv and friends: bulk rename inside $EDITOR

    # -------------------------------------------------------------------------
    # Languages
    # -------------------------------------------------------------------------
    rustup # toolchain manager; the toolchains live in ~/.rustup, outside Nix
    uv # Python packages, projects and interpreters

    # -------------------------------------------------------------------------
    # Data
    # -------------------------------------------------------------------------
    exiftool # reads and writes media metadata
    jq # JSON processor
  ];
}
