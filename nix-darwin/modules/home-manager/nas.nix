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
    ./programs/zellij.nix
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
    just # task runner; the Synology recipes in ../../../Justfile run here
    ripgrep # fast grep
    starship # prompt; .zshrc initialises it, as on the other machines
    zoxide # directory jumper, behind `z`

    # -------------------------------------------------------------------------
    # Git
    # -------------------------------------------------------------------------
    git # programs/git.nix configures it; this provides the binary
    delta # syntax-highlighted git diffs
    difftastic # diffs by syntax tree rather than by line
    # DSM ships gpg but no pinentry, and gpg routes every use of a secret key
    # through the agent, so without one a key cannot even be imported. The
    # curses build is the one that works over SSH.
    pinentry-curses

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
    # Remote access
    # -------------------------------------------------------------------------
    # The server half of the mosh in the MacBook's packages.nix. mosh starts it
    # over SSH as a plain command, and DSM gives that shell
    # /usr/bin:/bin:/usr/sbin:/sbin only, so the client has to be told where it
    # is: `mosh --server='~/.nix-profile/bin/mosh-server' nas`. See the README.
    mosh # SSH that survives roaming and suspend

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
    convmv # converts filenames between encodings
    p7zip # 7z archives
    renameutils # qmv and friends: bulk rename inside $EDITOR

    # -------------------------------------------------------------------------
    # Languages
    # -------------------------------------------------------------------------
    rustup # toolchain manager; the toolchains live in ~/.rustup, outside Nix
    uv # Python packages, projects and interpreters

    # -------------------------------------------------------------------------
    # Media
    # -------------------------------------------------------------------------
    exiftool # reads and writes media metadata
    flac # encodes and decodes the FLAC lossless audio format

    # -------------------------------------------------------------------------
    # Data
    # -------------------------------------------------------------------------
    jq # JSON processor
  ];

  # DSM has glibc but not its ldd, and neither Entware nor SynoCommunity puts
  # one on the box. VS Code Remote-SSH installs the musl build of the server CLI
  # on every x86_64 Linux host, and that build runs `ldd --version` to tell a
  # glibc host from a musl one. With no ldd it settles on musl, looks for
  # /lib/ld-musl-x86_64.so.1, finds nothing and refuses to start: "The remote
  # host does not meet the prerequisites for running VS Code Server".
  #
  # glibc's own ldd is a shell wrapper around the dynamic loader, so this is that
  # wrapper with the two modes anything here asks for. The loader reports the
  # glibc actually in use, 2.36, well over the 2.28 the server wants.
  #
  # Not the ldd from glibc.bin, which is a wrapper around the *store* loader and
  # so answers for a glibc nothing outside /nix links against. It would read
  # as a pass on a DSM too old to run the server, which is the one thing the
  # question is asked to find out. No packaged ldd can answer for DSM: glibc
  # bakes the version into the script at build time, so every copy reports the
  # glibc it was built beside.
  #
  # Two other ways out, both tried on the box and both worse:
  #
  #   remote.SSH.useExecServer=false drops the extension back to the installer
  #   that predates the CLI, which reads the version out of libc.so.6 and wants
  #   no ldd. It exits 0 here. The setting is client-wide though, so it moves
  #   every other host onto the older path to fix this one.
  #
  #   VSCODE_SERVER_CUSTOM_GLIBC_LINKER makes the CLI skip the check and still
  #   choose the glibc server, and on its own it changes nothing about how the
  #   server starts. It also skips the libstdc++ check, which passes honestly,
  #   and prints "Server stability is not guaranteed" on every connect.
  home.file.".local/bin/ldd" = {
    executable = true;
    text = ''
      #!/bin/sh
      loader=/lib/ld-linux-x86-64.so.2

      if [ "$1" = --version ]; then
        "$loader" --version |
          sed -n "1s/^ld\.so \(([^)]*)\) stable release version \([0-9][0-9.]*\)\./ldd \1 \2/p"
        exit 0
      fi

      exec "$loader" --list "$@"
    '';
  };

  # The same installer reads the word size from `getconf LONG_BIT`, which DSM
  # also leaves out. glibc's own getconf answers every variable, so take that
  # rather than write a second script: only ldd has a reason to be hand-rolled.
  #
  # Linked on its own, not through home.packages, because the Nix profile is not
  # on $PATH in the shell this has to serve, and putting it there would also
  # hand every non-interactive shell the ldd, ldconfig and locale beside it.
  #
  # GNU_LIBC_VERSION is the one answer to distrust: it reports the glibc this
  # binary was built against, 2.42, not DSM's 2.36. The installer asks only
  # LONG_BIT, and anything asking the version question goes through ldd above.
  home.file.".local/bin/getconf".source = "${pkgs.glibc.bin}/bin/getconf";

  # .zshrc puts ~/.local/bin on $PATH, but .zshrc is read by interactive shells
  # only. Remote-SSH runs the CLI under `ssh -T` with no command, which is a
  # non-interactive login shell: .zshenv and .zprofile, then nothing. This lands
  # in hm-session-vars.sh, which both of those source, so that shell finds ldd.
  home.sessionPath = [ "$HOME/.local/bin" ];

  # gpg finds its pinentry through this file, and DSM's default path points at
  # a binary that does not exist here. loopback lets a passphrase be piped in
  # for an unattended import, which is the only way in before a pinentry is on
  # the box at all.
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    allow-loopback-pinentry
    default-cache-ttl 3600
    max-cache-ttl 28800
  '';
}
