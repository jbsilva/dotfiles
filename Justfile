# Dotfiles task runner.
#
#   just            list every recipe
#   just switch     apply the nix-darwin configuration
#
# `just` is declared in nix-darwin/modules/packages.nix.

# The nix-darwin configuration in flake.nix is named after this host.
host := "M4"
flake := justfile_directory() / "nix-darwin"

# Show the available recipes
default:
    @just --list --unsorted

# ---------------------------------------------------------------------------
# nix-darwin
# ---------------------------------------------------------------------------

# Build and activate the configuration (needs sudo)
switch:
    sudo darwin-rebuild switch --flake {{ flake }}#{{ host }}

# Same as `switch`, via nh: nicer output and an automatic generation diff
nhs:
    nh darwin switch {{ flake }} -H {{ host }}

# Build without activating. Use this to check a change is valid.
build:
    nix build --no-link {{ flake }}#darwinConfigurations.{{ host }}.system

# Show what a rebuild would change, without activating it
diff:
    nix build --out-link /tmp/dotfiles-next {{ flake }}#darwinConfigurations.{{ host }}.system
    nvd diff /run/current-system /tmp/dotfiles-next

# Update every flake input
update:
    nix flake update --flake {{ flake }}

# Update a single input, e.g. `just update-input nixpkgs`
update-input input:
    nix flake update {{ input }} --flake {{ flake }}

# List the system generations
generations:
    darwin-rebuild --list-generations

# Collect garbage older than 14 days and optimise the store
gc:
    sudo nix-collect-garbage --delete-older-than 14d
    nix store optimise

# ---------------------------------------------------------------------------
# Quality
# ---------------------------------------------------------------------------

# Run every check: the hooks, plus the two things they cannot do
check: lint check-flake scan

# Run every hook over the whole repo (format, lint and spell check)
lint:
    prek run --all-files

# Evaluate the whole darwin configuration. Not a prek hook: it is far slower
# than the rest and only makes sense on the flake as a whole, not per file.
check-flake:
    nix flake check {{ flake }}

# -c is explicit: gitleaks does not reliably auto-discover .gitleaks.toml in
# `git` mode, and without it the known false positives come back.

# Scan the whole history for secrets (the hook only sees staged changes)
scan:
    gitleaks git -c .gitleaks.toml --no-banner --redact --verbose

# Needs docker (on this machine: `colima start`). Not part of `just check`,
# which must stay fast and dependency-free.

# Run the shell config against WSL, Synology and bare-Linux containers
test-shell scenario="all":
    ./scripts/test-shell-docker.sh {{ scenario }}

# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------

# Format everything. Same hooks as `just lint`: the formatting ones rewrite
# files in place, so there is no separate format-only pass.
fmt: lint

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

# Install the git hooks (run once per clone)
hooks:
    # An earlier version of this repo pointed core.hooksPath at .githooks/.
    # prek installs into .git/hooks/, which git ignores while hooksPath is set,
    # so clear it or the hooks silently never run.
    -git config --unset core.hooksPath
    prek install
    @echo "prek hooks installed"

# Nix provides only the rustup binary; the toolchains themselves live in
# ~/.rustup so that rust-toolchain.toml, nightly and extra targets work.
# rust-src and rust-analyzer come from the toolchain so they never drift out of
# sync with rustc.

# Install the default Rust toolchain and its components (run once)
rust-setup:
    rustup default stable
    rustup component add rust-analyzer rust-src clippy rustfmt
    @echo
    @rustc --version
    @cargo --version
    @echo "rust-analyzer: $(rustup which rust-analyzer)"

# Measure interactive shell startup time
bench-shell:
    hyperfine --warmup 3 'zsh -i -c exit'
