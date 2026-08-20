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

# Evaluate the whole darwin configuration (slow; not a prek hook)
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

# Same hooks as `just lint`: the formatting ones rewrite files in place, so
# there is no separate format-only pass.

# Format everything
fmt: lint

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

# Install the git hooks (run once per clone)
hooks:
    # prek installs into .git/hooks/, which git ignores if core.hooksPath is
    # set to anything else.
    -git config --unset core.hooksPath
    prek install
    @echo "prek hooks installed"

# Refresh the completion dumps committed in .zsh/completions/
#
# These are checked in rather than generated at shell startup: the tools are not
# on every machine, and `pants complete` is interactive -- run outside a Pants
# project it prompts "Would you like to configure . as a Pants project?", which
# would hang a shell start. Tools that generate cleanly and fast (uv, uvx, pixi)
# are cached automatically instead; see the Completions section of .zshrc.
#
# pants must run from inside a Pants project, so point this at one:
#   just completions ~/Dev/Hoppe/fleet-connect-serverless

# Refresh the completion dumps in .zsh/completions/ (pass a Pants dir for pants)
completions pants_dir="":
    #!/usr/bin/env zsh
    set -uo pipefail
    cd {{ justfile_directory() }}
    out=.zsh/completions
    # ${=2} forces word splitting: zsh does not split unquoted parameters the
    # way bash does, so "$2" alone would be run as one long command name.
    gen() { print -n "  $1 ... "; if ${=2} > "$out/_$1.tmp" 2>/dev/null && [[ -s $out/_$1.tmp ]]; then mv "$out/_$1.tmp" "$out/_$1"; print ok; else rm -f "$out/_$1.tmp"; print "skipped (not installed or failed)"; fi }
    (( $+commands[hugo] ))    && gen hugo    "hugo completion zsh"
    (( $+commands[ruff] ))    && gen ruff    "ruff generate-shell-completion zsh"
    (( $+commands[zellij] ))  && gen zellij  "zellij setup --generate-completion zsh"
    (( $+commands[poetry] ))  && gen poetry  "poetry completions zsh"
    if [[ -n "{{ pants_dir }}" ]]; then
      print -n "  pants ... "
      if (cd "{{ pants_dir }}" && pants complete --shell=zsh) > "$out/_pants.tmp" 2>/dev/null && [[ -s $out/_pants.tmp ]]; then
        mv "$out/_pants.tmp" "$out/_pants"; print ok
      else
        rm -f "$out/_pants.tmp"; print "failed -- is {{ pants_dir }} a Pants project?"
      fi
    else
      print "  pants ... skipped (pass a Pants project dir to refresh it)"
    fi
    print "\nReview with 'git diff .zsh/completions' before committing."

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

# Profile shell startup AND Tab-completion latency
#
# bench-shell only measures startup. Completion needs a real terminal -- zsh
# will not run its line editor without a tty, so fzf-tab and zsh-patina are
# never exercised by `zsh -i -c exit`. This drives a pty and times how long
# each Tab takes to produce output.
#
#   just profile-shell                  a default set of completions
#   just profile-shell 'ls ~/dot'       one specific case
#   just profile-shell '' --cold        as a shell is right after `just switch`

# Profile shell startup AND Tab-completion latency
profile-shell *ARGS:
    ./scripts/profile-shell.py {{ ARGS }}

# ---------------------------------------------------------------------------
# Synology
#
# Everything above runs on this MacBook: darwin-rebuild, prek and gitleaks are
# not installed on the NAS. These drive it over SSH instead.
# ---------------------------------------------------------------------------

# Pull and activate the home-manager profile on the Synology
nas-switch:
    #!/usr/bin/env bash
    set -euo pipefail
    ssh nas '
      set -eu
      . ~/.nix-profile/etc/profile.d/nix.sh
      /usr/local/bin/git -C ~/dotfiles pull --ff-only
      export TMPDIR=$HOME/.cache/nix-install
      nix build -o ~/.hm-generation \
        "$HOME/dotfiles/nix-darwin#homeConfigurations.\"julio@nas\".activationPackage"
      ~/.hm-generation/activate
    '

# What the next nas-switch would change, without activating it
nas-diff:
    #!/usr/bin/env bash
    set -euo pipefail
    ssh nas '
      set -eu
      . ~/.nix-profile/etc/profile.d/nix.sh
      export TMPDIR=$HOME/.cache/nix-install
      nix build --no-link --print-out-paths \
        "$HOME/dotfiles/nix-darwin#homeConfigurations.\"julio@nas\".activationPackage"
    '
