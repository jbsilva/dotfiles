{ pkgs, ... }:
{
  # Mostly CLI and common developer tools.
  # Homebrew usually has pre-compiled binaries, and tends to update them more often than nixpkgs,
  # see homebrew.nix.
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
    duf # readable `df`. Alternative: `dysk`
    btop # .zshrc aliases htop -> btop
    procs # `ps` with colour, tree view and search
    ripgrep # fast grep (already relied on by nvim/telescope)
    ack # Perl-based grep-alike
    dua # interactive disk usage browser -- the terminal DaisyDisk
    ouch # one command to (de)compress any archive format
    hexyl # hex viewer
    zsh-patina # shell syntax highlighter; CLI for themes and `check`
    vivid # generates LS_COLORS from a theme; .zshrc prefers it over dircolors
    chafa # renders images in the terminal; backs the `icat` alias under Ghostty
    oath-toolkit # provides oathtool, behind the otp/otp8/otp8hex aliases

    # -------------------------------------------------------------------------
    # Git
    # -------------------------------------------------------------------------
    git # home-manager configures it; this provides the binary
    delta # syntax-highlighted git diffs; wired up in home-manager's git.nix
    # lazygit     # Fork is the git UI
    # difftastic  # delta is the configured diff renderer
    git-absorb # auto-routes fixups into the right commit during rebase
    # Not enabled, but worth a look one day:
    # jujutsu   # `jj`: git-compatible VCS
    # gh-dash   # TUI dashboard of GitHub PRs and issues, reusing the gh auth

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
    jnv # interactive jq: build the filter with live preview of the result
    gron # flattens JSON into greppable lines
    csvlens # `less` for CSV -- paging, column align, search, no spreadsheet
    miller # awk/sed/cut for CSV, TSV and JSON, keeping the structure

    # -------------------------------------------------------------------------
    # Development
    # -------------------------------------------------------------------------
    just # command runner; see the Justfile at the repo root
    just-lsp # language server; the VS Code extension expects it on $PATH
    watchexec # re-run a command when files change
    mprocs # run several long-running commands side by side in one terminal
    hyperfine # statistically sound benchmarking
    tokei # lines-of-code stats
    shfmt # shell script formatter
    stylua # Lua formatter
    ruff # Python linter/formatter
    typos # source-code spell checker
    actionlint # linter for GitHub Actions workflows
    zizmor # security auditor for GitHub Actions workflows
    prek # runs .pre-commit-config.yaml; drop-in pre-commit replacement in Rust
    ast-grep # structural search & rewrite, by syntax tree rather than regex
    tealdeer # `tldr` client: practical examples instead of full man pages
    uv # fast Python package/venv manager
    prettier # formats JS/TS, JSON, CSS, Markdown and YAML
    openapi-generator-cli # generates clients and servers from an OpenAPI spec
    opencode # terminal coding agent

    # -------------------------------------------------------------------------
    # Containers
    # Aimed at driving the dockerized Synology over SSH as much as local work.
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

    # -------------------------------------------------------------------------
    # Networking
    # -------------------------------------------------------------------------
    xh # ergonomic HTTP client (HTTPie-compatible, Rust-fast)
    hurl # HTTP requests as plain text files: chain, assert, run in CI
    trippy # traceroute and ping in one TUI; the tool for "why is the NAS slow"
    curlFull # curl with every optional protocol compiled in
    wget # non-interactive downloader
    mosh # SSH that survives roaming and suspend
    iperf # bandwidth measurement between two hosts
    rsync # incremental file transfer

    # -------------------------------------------------------------------------
    # Infrastructure
    # -------------------------------------------------------------------------
    awscli2 # AWS CLI
    terraform
    terragrunt # Terraform wrapper: DRY configs and state locking
    tflint # Terraform linter
    hclfmt # formatter for HCL (Terraform, Terragrunt)

    # -------------------------------------------------------------------------
    # Languages & runtimes
    # -------------------------------------------------------------------------
    go
    nodejs_24

    # rustup, not a nixpkgs toolchain: only it honours rust-toolchain.toml and
    # offers nightly and `rustup target add`. Toolchains live in ~/.rustup,
    # outside Nix; `just rust-setup` bootstraps them and .zshrc puts
    # ~/.cargo/bin first so the shims win.
    rustup

    # -------------------------------------------------------------------------
    # GNU userland
    # These install under the plain names and so shadow the BSD ones on $PATH;
    # /usr/bin/find and friends stay reachable by full path. No g-prefixed
    # aliases -- that is the separate coreutils-prefixed package -- so scripts
    # feature-detect instead, as .zsh/rm_regex.zsh does.
    # -------------------------------------------------------------------------
    bash # macOS ships 3.2.57 from 2007; this puts 5.x first on $PATH
    coreutils # ls, cp, date, stat...
    findutils # find, xargs
    gawk # awk
    gnugrep # grep
    gnused # sed
    gnutar # tar

    # -------------------------------------------------------------------------
    # Files, archives & media
    # -------------------------------------------------------------------------
    p7zip # 7z archives
    the-unarchiver # unpacks most archive formats
    exiftool # photo metadata; drives the exif_* aliases in .zshrc
    file-rename # Perl `rename`: bulk renames by regex
    renameutils # qmv/qcp, behind the qmv* aliases
    # yt-dlp        # via Homebrew: updates far more often than nixpkgs

    # -------------------------------------------------------------------------
    # Terminal & editors
    # -------------------------------------------------------------------------
    neovim # the editor; config in .config/nvim
    tree-sitter # nvim-treesitter's `main` branch needs it to build parsers
    zellij # terminal multiplexer
    # tmux        # zellij is the multiplexer
    # wezterm     # Ghostty is the terminal
    # sesh        # session picker, only ever used via tmux
    glow # render markdown in the terminal
    # ghostty-bin   # via Homebrew cask

    # -------------------------------------------------------------------------
    # macOS applications & integration
    # -------------------------------------------------------------------------
    mas # Mac App Store CLI
    loopwm # window snapping (Loop)
    raycast # launcher and command palette
    shottr # screenshots with scrolling capture, OCR and annotation
    swiftdefaultapps # backs the default-apps activation script
    iina # video player
    notion-app # notes and docs
    slack # chat
  ];
}
