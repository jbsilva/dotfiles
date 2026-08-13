#!/usr/bin/env zsh
# Run Renovate against a local repo and print the pending dependency updates as a table.
#   renovate-check [DIR]
#     DIR   repo to check (default: current directory)
#
# Updates Renovate is holding back under minimumReleaseAge (its own "pendingChecks" flag, meaning
# it would NOT open a PR for them yet) are excluded from the table and instead summarized on a
# separate line, unless they are security fixes (Renovate's isVulnerabilityAlert, which bypasses
# minimumReleaseAge on its own): those always show in the table, flagged in the SECURITY column.
#
# The DIGEST column always shows Renovate's resolved newDigest ("-" when the manager doesn't pin by
# digest), so digest-pinned deps (e.g. GitHub Actions pinned to a commit SHA) don't need a re-run.
#
# The GitHub token comes from `gh auth token`, so nothing secret lands in your shell history or
# argv. Without gh (or when logged out) it still runs, but GitHub-sourced updates (actions,
# pre-commit repos, python-version) get rate-limited and may be missed.
#
# Env overrides:
#   RENOVATE_VERSION   npm version of renovate to run via npx (default: latest)
renovate-check() {
  emulate -L zsh
  setopt local_options pipe_fail

  while [[ "$1" == -* ]]; do
    case "$1" in
      -h|--help)
        print -r -- "usage: renovate-check [DIR]"
        return 0 ;;
      *) print -ru2 -- "renovate-check: unknown option '$1'"; return 2 ;;
    esac
    shift
  done

  local dir="${1:-$PWD}"
  if [[ ! -d "$dir" ]]; then
    print -ru2 -- "renovate-check: not a directory: $dir"
    return 2
  fi

  # Hard requirements; gh is optional (see header).
  local cmd
  for cmd in npx jq column; do
    if ! (( $+commands[$cmd] )); then
      print -ru2 -- "renovate-check: '$cmd' not found in PATH"
      return 2
    fi
  done

  local token=""
  if (( $+commands[gh] )); then
    token="$(gh auth token 2>/dev/null)"
  fi
  if [[ -z "$token" ]]; then
    print -ru2 -- "renovate-check: no GitHub token (gh not authed); GitHub-sourced updates may be rate-limited."
  fi

  local logfile
  logfile="$(mktemp -t renovate-check.XXXXXX.jsonl)" || return 1

  print -ru2 -- "renovate-check: scanning $dir ..."
  (
    cd "$dir" || exit 1
    LOG_LEVEL=debug \
    RENOVATE_LOG_FILE="$logfile" \
    GITHUB_COM_TOKEN="$token" \
    npx --yes --package "renovate@${RENOVATE_VERSION:-latest}" -- renovate \
      --platform=local --dry-run=full --update-not-scheduled=true >/dev/null 2>&1
  )
  local rc=$?
  if (( rc != 0 )); then
    print -ru2 -- "renovate-check: renovate exited $rc; log kept at $logfile"
    return $rc
  fi

  # Pull every dep that has a pending, actionable update out of the debug log. The `?` and
  # `objects` guards skip the unrelated config dumps that also carry a top-level `.config` object.
  # An update with pendingChecks=true is one Renovate itself would NOT yet turn into a PR (it is
  # waiting out minimumReleaseAge), so it is dropped here unless isVulnerabilityAlert overrides it.
  local rows
  rows="$(jq -r '
    select(.config | type == "object") | .config | to_entries[]
    | .key as $mgr | .value[]? | objects | .packageFile as $file
    | .deps[]? | select((.updates | length) > 0)
    | . as $d | .updates[]
    | select((.pendingChecks // false) == false or (.isVulnerabilityAlert // false) == true)
    | [$mgr, $file, ($d.depName // $d.packageName), ($d.depType // "-"),
       ($d.currentValue // $d.currentVersion // "?"), .newValue,
       (.newDigest // "-"), .updateType,
       (if (.isVulnerabilityAlert // false) then "security" else "-" end)]
    | @tsv
  ' "$logfile" | sort -u)"

  # Updates withheld solely by minimumReleaseAge: surfaced separately, not as actionable rows.
  local held
  held="$(jq -r '
    select(.config | type == "object") | .config | to_entries[]
    | .value[]? | objects
    | .deps[]? | select((.updates | length) > 0)
    | . as $d | .updates[]
    | select((.pendingChecks // false) == true and (.isVulnerabilityAlert // false) == false)
    | "  \($d.depName // $d.packageName) -> \(.newVersion // .newValue) (released \(.newVersionAgeInDays // 0)d ago)"
  ' "$logfile" | sort -u)"

  rm -f "$logfile"

  if [[ -z "$rows" ]]; then
    print -r -- "No pending updates."
  else
    { print -r -- $'MANAGER\tFILE\tPACKAGE\tTYPE\tCURRENT\tNEW\tDIGEST\tUPDATE\tSECURITY'
      print -r -- "$rows"
    } | column -t -s $'\t'
  fi

  if [[ -n "$held" ]]; then
    print -r --
    print -r -- "Held back by minimumReleaseAge (not yet actionable):"
    print -r -- "$held"
  fi
}
