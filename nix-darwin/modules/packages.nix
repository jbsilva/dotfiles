{ pkgs, ... }:
{
  # Packages are grouped by purpose rather than alphabetically so it is obvious
  # what is installed and why. Commented-out entries are deliberate records of
  # things tried and rejected, or handled by Homebrew instead (see homebrew.nix).
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
    gitleaks # secret scanner; used by .githooks/pre-commit
    age # modern, small file encryption
    sops # encrypted secrets in git, works with age

    # -------------------------------------------------------------------------
    # Modern replacements for classic tools
    # These do not shadow the originals; see .zshrc for the opt-in aliases.
    # -------------------------------------------------------------------------
    eza # ls with git status, tree mode, icons (replaces the dead `k` plugin)
    bat # cat with syntax highlighting and paging
    fd # far friendlier and faster `find`
    sd # sed for humans: literal strings by default, no escaping hell
    dust # visual `du` (replaces the `list`/`listh` aliases)
    duf # readable `df`
    btop # replaces htop; .zshrc aliases htop -> btop
    procs # `ps` with colour, tree view and search
    ripgrep # fast grep (already relied on by nvim/telescope)
    dua # interactive disk usage browser -- the terminal DaisyDisk
    ouch # one command to (de)compress any archive format
    hexyl # hex viewer

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
    fzf # fuzzy finder (was installed out-of-band via ~/.fzf.zsh; now declarative)
    zoxide # frecency-based cd; initialised in .zshrc
    yazi # fast terminal file manager with previews
    carapace # completions for hundreds of CLIs; initialised in .zshrc

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
    watchexec # re-run a command when files change
    hyperfine # statistically sound benchmarking (used to measure zsh startup)
    tokei # lines-of-code stats
    shfmt # shell script formatter
    stylua # Lua formatter, used by conform.nvim for this nvim config
    ruff # Python linter/formatter, used by conform.nvim
    typos # source-code spell checker (this repo already has typos.toml)
    actionlint # linter for GitHub Actions workflows
    ast-grep # structural search & rewrite, by syntax tree rather than regex
    tealdeer # `tldr` client: practical examples instead of full man pages
    uv # fast Python package/venv manager (was installed out-of-band)
    # Not installed here on purpose: `mise` would supersede the nvm block still
    # in .zshrc (one tool for node/python/go versions, .tool-versions,
    # per-directory activation), but nixpkgs has no darwin binary cached at the
    # pinned revision, so it compiles for ~20 min on every flake update.
    # Add it when the nvm block actually gets in the way.
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

    # Rust, via rustup rather than a pinned nixpkgs toolchain.
    #
    # Rust does not need per-project versions for the reason Python does --
    # the compiler is backwards compatible and breaking changes are gated
    # behind editions, so a newer rustc still builds older crates. What it does
    # need is toolchain *switching*, and rustup is the only thing that:
    #
    #   * honours rust-toolchain.toml. nixpkgs cargo ignores it silently, so a
    #     local build can differ from CI without any warning.
    #   * provides nightly (`cargo +nightly`) and extra targets
    #     (`rustup target add wasm32-unknown-unknown`)
    #   * keeps clippy/rustfmt/rust-analyzer/rust-src on the *same* toolchain,
    #     so rust-analyzer never drifts out of sync with rustc
    #
    # Only the rustup binary is pinned here; the toolchains it downloads live in
    # ~/.rustup and are deliberately outside Nix -- the same trade uv makes for
    # Python interpreters. For a genuinely reproducible build of one project,
    # use a per-project flake (fenix/oxalica + crane), not the global toolchain.
    #
    # Bootstrap once with `just rust-setup`.
    # .zshrc already puts ~/.cargo/bin first, so the rustup shims win.
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
    ack # kept: the `ack` alias and muscle memory
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
    git # kept explicitly: home-manager configures it, this provides the binary

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
