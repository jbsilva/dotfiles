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

# Run every check
check: check-nix check-shell check-actions check-typos scan

# Lint the GitHub Actions workflows
check-actions:
    actionlint .github/workflows/*.yml

# Evaluate the flake and lint the Nix files
check-nix:
    nix flake check {{ flake }}
    statix check {{ flake }}
    deadnix --fail {{ flake }}

# Run the shell config against WSL, Synology and bare-Linux containers
# Needs docker (on this machine: `colima start`). Not part of `just check`,
# which must stay fast and dependency-free.
test-shell scenario="all":
    ./scripts/test-shell-docker.sh {{ scenario }}

# Lint shell scripts
check-shell:
    #!/usr/bin/env bash
    set -euo pipefail
    # shellcheck only understands sh/bash/dash/ksh, so route by actual shell.
    shellcheck \
        .githooks/pre-commit \
        scripts/hosts.sh \
        scripts/test-shell-docker.sh \
        linux/Xsetup \
        linux/bin/nvidia-force_comp_pipeline.sh
    # zsh scripts get a parse check instead (linux/bin/keyboards.sh is zsh too).
    for f in .zshrc .zsh/*.zsh .zsh/zshrc_* scripts/shell-selftest.zsh linux/bin/keyboards.sh; do
        [ -e "$f" ] || continue
        zsh -n "$f" || { echo "syntax error: $f" >&2; exit 1; }
    done
    echo "shell OK"

# Spell-check the repo (configured by typos.toml)
check-typos:
    typos

# Scan the whole history for secrets
# -c is explicit: gitleaks does not reliably auto-discover .gitleaks.toml in
# `git` mode, and without it the known false positives come back.
scan:
    gitleaks git -c .gitleaks.toml --no-banner --redact --verbose

# Scan only what is currently staged (what the pre-commit hook runs)
scan-staged:
    gitleaks git --staged -c .gitleaks.toml --no-banner --redact --verbose

# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------

# Format everything
fmt: fmt-nix fmt-shell fmt-lua

fmt-nix:
    nixfmt {{ flake }}

fmt-shell:
    shfmt -w -i 2 -ci .githooks/pre-commit hosts.sh

fmt-lua:
    stylua .config/nvim

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

# Enable the repo-local git hooks (run once per clone)
hooks:
    git config core.hooksPath .githooks
    @echo "pre-commit secret scanning enabled"

# Measure interactive shell startup time
bench-shell:
    hyperfine --warmup 3 'zsh -i -c exit'
