#!/usr/bin/env bash
#
# Secret scan over staged changes. Run as a local hook from
# .pre-commit-config.yaml; enable with `just hooks`.
#
# Files linked out of this repo into ~/.config are written to by the
# applications themselves, and .gitignore uses an allow-list to keep the rest
# out. This is the second line of defence: it scans what is actually staged, so
# a file deliberately force-added (`git add -f`) is still checked.
#
# Bypass for a single commit (use sparingly, and know what you are committing):
#   git commit --no-verify

set -euo pipefail

# Nothing staged: nothing to scan.
if git diff --cached --quiet; then
  exit 0
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  cat >&2 <<'EOF'
pre-commit: gitleaks not found, skipping secret scan.
            Install it so this hook can protect you:
              nix profile install nixpkgs#gitleaks
            (it is also declared in nix-darwin/modules/packages.nix)
EOF
  exit 0
fi

echo "pre-commit: scanning staged changes for secrets..." >&2

# Pass the config explicitly. gitleaks documents "(target path)/.gitleaks.toml"
# as a fallback, but it is not picked up reliably in `git` mode, and silently
# falling back to the default ruleset would resurrect the known false positives.
repo_root="$(git rev-parse --show-toplevel)"
config="$repo_root/.gitleaks.toml"

gitleaks_args=(git --staged --no-banner --redact --verbose)
if [ -f "$config" ]; then
  gitleaks_args+=(--config "$config")
fi

# `git` mode with --staged scans only what is about to be committed.
if ! gitleaks "${gitleaks_args[@]}"; then
  cat >&2 <<'EOF'

pre-commit: potential secrets found in staged changes -- commit aborted.

  * If these are real credentials: unstage them, rotate the credential, and
    add the path to .gitignore.
  * If this is a false positive: add a narrowly scoped rule to .gitleaks.toml
    (prefer a path/regex allowlist over disabling the rule).
  * To commit anyway: git commit --no-verify

EOF
  exit 1
fi

echo "pre-commit: no secrets detected." >&2
