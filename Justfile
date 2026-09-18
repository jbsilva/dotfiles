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

# Upgrade the Homebrew formulae and casks
#
# Separate from `just switch` on purpose. homebrew.onActivation.upgrade is off,
# so activation installs and uninstalls to match homebrew.nix and changes no
# version. This is the deliberate half: mactex, microsoft-office and steam are
# in the list, so it can be a long download.
#
# No `brew update`. nix-homebrew mounts the taps read-only out of /nix/store, so
# it stops on `.../homebrew-core/.git: Permission denied`. What a tap offers
# moves with its flake input, which is `just update` followed by `just switch`.
#
# No `--greedy` either. It reaches the casks that carry `auto_updates true`,
# which are the apps that already update themselves, so it re-downloads whole
# bundles nobody asked it to: adobe-creative-cloud, microsoft-office and
# visual-studio-code among them. `brew upgrade` covers formulae and casks
# alike; pass --greedy by hand for a cask that is genuinely stuck.
brew-upgrade:
    brew upgrade

# Collect garbage older than 14 days and optimise the store
gc:
    sudo nix-collect-garbage --delete-older-than 14d
    nix store optimise

# `sudo -v` only moves the first password prompt to the front. The build that
# follows can outlast the sudo timestamp, so `gc` may ask again.
#
# Every line is a recipe of its own, so run any step alone when only that step
# is wanted. just stops at the first line that fails.

# Update, activate, upgrade Homebrew and collect garbage, in that order
up:
    sudo -v
    just update
    just nhs
    just brew-upgrade
    just gc

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
# not installed on the NAS.
#
# Each recipe below serves both sides. On the NAS it does the work; anywhere
# else it drives the box over SSH. `just` reaches the NAS through
# home-manager/nas.nix.
#
# The test is /usr/syno, DSM's own tree, rather than the platform: WSL is
# x86_64-linux as well, so a `[linux]` attribute would send it down the local
# branch, where the build succeeds and activation then runs against the wrong
# $HOME.
#
# No shebang: a shebang recipe runs from a file just writes under /tmp, and DSM
# mounts that noexec. Each body is one shell command instead, which is also
# what lets the branch cover the commands inside it.
#
# The SSH branch sources nix.sh to put `just` on $PATH, and so reads the NAS
# copy of this file as it stands before the pull inside it. A change to a
# recipe here therefore takes effect on the run after the one that ships it.
#
# HOME_MANAGER_BACKUP_EXT is what `home-manager.backupFileExtension` sets for
# the MacBook. Standalone home-manager takes it from the environment instead,
# and without it activation stops at the first unmanaged file sitting where a
# link belongs, rather than moving it aside.
# ---------------------------------------------------------------------------

# `nas` is the LAN address. Set NAS_HOST=nast, the Tailscale alias, from off the LAN.
nas_host := env("NAS_HOST", "nas")

# Pull and activate the home-manager profile on the Synology
nas-switch:
    if [ -d /usr/syno ]; then \
      /usr/local/bin/git -C ~/dotfiles pull --ff-only && \
      TMPDIR=$HOME/.cache/nix-install nix build -o ~/.hm-generation \
        "$HOME/dotfiles/nix-darwin#homeConfigurations.\"julio@nas\".activationPackage" && \
      HOME_MANAGER_BACKUP_EXT=hm-bak ~/.hm-generation/activate; \
    else \
      ssh {{ nas_host }} '. ~/.nix-profile/etc/profile.d/nix.sh && just -f ~/dotfiles/Justfile nas-switch'; \
    fi

# What the next nas-switch would change, without activating it
nas-diff:
    if [ -d /usr/syno ]; then \
      TMPDIR=$HOME/.cache/nix-install nix build --no-link --print-out-paths \
        "$HOME/dotfiles/nix-darwin#homeConfigurations.\"julio@nas\".activationPackage"; \
    else \
      ssh {{ nas_host }} '. ~/.nix-profile/etc/profile.d/nix.sh && just -f ~/dotfiles/Justfile nas-diff'; \
    fi
