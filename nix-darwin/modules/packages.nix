{ pkgs, ... }:
{
  # Grouped by purpose rather than alphabetically. Commented-out entries are
  # deliberate: either rejected, or handled by Homebrew (see homebrew.nix).
  environment.systemPackages = with pkgs; [
    # -------------------------------------------------------------------------
    # Nix workflow
    # -------------------------------------------------------------------------
    nh # friendlier darwin-rebuild/home-manager wrapper: `nh darwin switch .`
    nix-output-monitor # tree-structured build output (`nom`); nh uses it
    nvd # diffs two generations: shows exactly what a rebuild changed
    nix-tree # interactive dependency explorer for a store path
    nil # Nix language server
    nixd # Nix language server with flake-aware completion
    nixfmt # official Nix formatter
    statix # lints Nix for antipatterns
    deadnix # finds unused Nix bindings (e.g. an unused `pkgs` argument)

    # -------------------------------------------------------------------------
    # Secrets & safety
    # -------------------------------------------------------------------------
    gitleaks # secret scanner; run by the pre-commit hook
    age # modern, small file encryption
    sops # encrypted secrets in git, works with age

    # -------------------------------------------------------------------------
    # Modern replacements for classic tools
    # These do not shadow the originals; see .zshrc for the opt-in aliases.
    # -------------------------------------------------------------------------
    eza # ls with git status, tree mode and icons
    bat # cat with syntax highlighting and paging
    fd # far friendlier and faster `find`
    sd # sed for humans: literal strings by default, no escaping hell
    dust # visual `du`
    duf # readable `df`
    btop # .zshrc aliases htop -> btop
    procs # `ps` with colour, tree view and search
    ripgrep # fast grep (already relied on by nvim/telescope)
    dua # interactive disk usage browser -- the terminal DaisyDisk
    ouch # one command to (de)compress any archive format
    hexyl # hex viewer
    zsh-patina # syntax highlighter used by the shell; CLI for themes and `check`
    vivid # generates LS_COLORS from a theme; .zshrc prefers it over dircolors
    chafa # renders images in the terminal; backs the `icat` alias under Ghostty
    oath-toolkit # provides oathtool, behind the otp/otp8/otp8hex aliases

    # -------------------------------------------------------------------------
    # Git
    # -------------------------------------------------------------------------
    lazygit # terminal git UI; covers most of what Fork/GitKraken are used for
    delta # syntax-highlighted, side-by-side git diffs
    difftastic # structural (AST-aware) diff: ignores pure reformatting
    git-absorb # auto-routes fixups into the right commit during rebase

    # -------------------------------------------------------------------------
    # Navigation & fuzzy finding
    # -------------------------------------------------------------------------
    fzf # fuzzy finder
    zoxide # frecency-based cd; initialised in .zshrc
    yazi # fast terminal file manager with previews

    # -------------------------------------------------------------------------
    # Data wrangling
    # -------------------------------------------------------------------------
    jq # JSON processor
    yq-go # the same for YAML/XML/TOML
    jless # pager for large JSON, like `less` for structured data
    gron # flattens JSON into greppable lines
    miller # awk/sed/cut for CSV, TSV and JSON, keeping the structure

    # -------------------------------------------------------------------------
    # Development
    # -------------------------------------------------------------------------
    just # command runner; see the Justfile at the repo root
    just-lsp # language server; the VS Code extension expects it on $PATH
    watchexec # re-run a command when files change
    hyperfine # statistically sound benchmarking
    tokei # lines-of-code stats
    shfmt # shell script formatter
    stylua # Lua formatter, used by conform.nvim for this nvim config
    ruff # Python linter/formatter, used by conform.nvim
    typos # source-code spell checker; config in typos.toml
    actionlint # linter for GitHub Actions workflows
    prek # runs .pre-commit-config.yaml; drop-in pre-commit replacement in Rust
    ast-grep # structural search & rewrite, by syntax tree rather than regex
    tealdeer # `tldr` client: practical examples instead of full man pages
    uv # fast Python package/venv manager
    # mise comes from Homebrew instead (see modules/homebrew.nix): nixpkgs has
    # no cached darwin build at the pinned revision and compiles it from source.
    prettier
    openapi-generator-cli
    hclfmt

    # -------------------------------------------------------------------------
    # Containers
    # Most of what runs on the Synology is dockerized, so these are aimed at
    # driving it over SSH as much as at local work.
    # -------------------------------------------------------------------------
    lazydocker # terminal UI for docker/compose
    dive # inspect a container image layer by layer
    ctop # top-like live metrics per container
    lnav # log navigator: merges/parses container and system logs

    # -------------------------------------------------------------------------
    # Synology / remote
    # -------------------------------------------------------------------------
    restic # fast deduplicating encrypted backups
    rclone # sync to and from cloud storage and the NAS
    croc # send a file between two machines with a one-time code
    sesh # zellij/tmux session manager, fuzzy-picks sessions by project

    # -------------------------------------------------------------------------
    # Networking
    # -------------------------------------------------------------------------
    xh # ergonomic HTTP client (HTTPie-compatible, Rust-fast)
    curlFull
    wget
    mosh # SSH that survives roaming and suspend
    iperf
    rsync

    # -------------------------------------------------------------------------
    # Infrastructure
    # -------------------------------------------------------------------------
    awscli2
    terraform
    terragrunt
    tflint

    # -------------------------------------------------------------------------
    # Languages & runtimes
    # -------------------------------------------------------------------------
    go
    nodejs_24

    # rustup rather than a pinned nixpkgs toolchain, because only rustup:
    #   * honours rust-toolchain.toml (nixpkgs cargo ignores it silently)
    #   * provides nightly and `rustup target add`
    #   * keeps clippy/rustfmt/rust-analyzer/rust-src on the same toolchain
    #
    # Only the rustup binary is pinned; toolchains live in ~/.rustup, outside
    # Nix. For a reproducible build of one project use a per-project flake
    # (fenix/oxalica + crane).
    #
    # Bootstrap with `just rust-setup`. .zshrc puts ~/.cargo/bin first, so the
    # rustup shims win.
    rustup

    # -------------------------------------------------------------------------
    # GNU userland
    # macOS ships ancient BSD variants; these provide the GNU behaviour scripts
    # expect. Prezto's gnu-utility module exposes them with a `g` prefix.
    # -------------------------------------------------------------------------
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    gnutar

    # -------------------------------------------------------------------------
    # Files, archives & media
    # -------------------------------------------------------------------------
    p7zip
    the-unarchiver
    exiftool # photo metadata; drives the exif_* aliases in .zshrc
    file-rename
    renameutils # qmv/qcp, behind the qmv* aliases
    ack
    # yt-dlp        # via Homebrew: updates far more often than nixpkgs

    # -------------------------------------------------------------------------
    # Terminal & editors
    # -------------------------------------------------------------------------
    neovim
    tree-sitter # REQUIRED by nvim-treesitter's `main` branch to build parsers
    tmux
    zellij
    wezterm
    glow # render markdown in the terminal
    # ghostty-bin   # via Homebrew cask

    # -------------------------------------------------------------------------
    # macOS applications & integration
    # -------------------------------------------------------------------------
    mas # Mac App Store CLI
    loopwm
    raycast
    shottr
    swiftdefaultapps # backs the default-apps activation script
    iina
    notion-app
    slack
    opencode
    git # home-manager configures it; this provides the binary

    # -------------------------------------------------------------------------
    # Handled elsewhere / deliberately disabled
    # -------------------------------------------------------------------------
    # firefox       # via Homebrew cask
    # vscode        # via Homebrew cask
    # warp-terminal # via Homebrew cask
    # hugo          # via Homebrew
    # ollama        # disabled: see activation/disable-ollama.nix
    # tailscale     # via Homebrew cask (tailscale-app)
  ];
}
