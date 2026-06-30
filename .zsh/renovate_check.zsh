#!/usr/bin/env zsh
# Run Renovate against a local repo and print the pending dependency updates as a table.
#   renovate-check [-d|--digests] [DIR]
#     -d, --digests   also show the new git SHA (needed to apply digest-pinned actions)
#     DIR             repo to check (default: current directory)
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

  local show_digests=""
  while [[ "$1" == -* ]]; do
    case "$1" in
      -d|--digests) show_digests=1 ;;
      -h|--help)
        print -r -- "usage: renovate-check [-d|--digests] [DIR]"
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

  # Pull every dep that has a pending update out of the debug log. The `?` and `objects`
  # guards skip the unrelated config dumps that also carry a top-level `.config` object.
  local rows
  rows="$(jq -r '
    select(.config | type == "object") | .config | to_entries[]
    | .key as $mgr | .value[]? | objects | .packageFile as $file
    | .deps[]? | select((.updates | length) > 0)
    | . as $d | .updates[]
    | [$mgr, $file, ($d.depName // $d.packageName), ($d.depType // "-"),
       ($d.currentValue // $d.currentVersion // "?"), .newValue,
       (.newDigest // "-"), .updateType]
    | @tsv
  ' "$logfile" | sort -u)"

  rm -f "$logfile"

  if [[ -z "$rows" ]]; then
    print -r -- "No pending updates."
    return 0
  fi

  # Columns: 1 MANAGER 2 FILE 3 PACKAGE 4 TYPE 5 CURRENT 6 NEW 7 DIGEST 8 UPDATE.
  local fields header
  if [[ -n "$show_digests" ]]; then
    fields='1-8'
    header=$'MANAGER\tFILE\tPACKAGE\tTYPE\tCURRENT\tNEW\tDIGEST\tUPDATE'
  else
    fields='1-6,8'
    header=$'MANAGER\tFILE\tPACKAGE\tTYPE\tCURRENT\tNEW\tUPDATE'
  fi

  { print -r -- "$header"; print -r -- "$rows" | cut -f"$fields"; } | column -t -s $'\t'
}
