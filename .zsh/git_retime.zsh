# Re-date a range of commits to sequential timestamps and GPG-sign them.
#   git-retime-sign <iso-base-date> <range|upstream|--root> [interval-seconds]
#   --root also rewrites the initial commit.
#   GIT_RETIME_TZ overrides the timezone (default Europe/Berlin).
git-retime-sign() {
  emulate -L zsh
  setopt local_options pipe_fail

  local base_date="$1" range="$2" interval="${3:-1}"
  local tz="${GIT_RETIME_TZ:-Europe/Berlin}"

  if [[ -z "$base_date" || -z "$range" ]]; then
    print -ru2 -- "usage: git-retime-sign <iso-base-date> <range|upstream|--root> [interval-seconds]"
    print -ru2 -- "  e.g. git-retime-sign 2026-06-02T11:25:00 origin/master..HEAD"
    print -ru2 -- "  e.g. git-retime-sign 2026-06-02T11:25:00 --root"
    return 2
  fi

  # Parse "A..B" into upstream/branch; a bare ref means "rebase current branch".
  local upstream branch root=""
  if [[ "$range" == *..* ]]; then
    upstream="${range%%..*}"; branch="${range##*..}"
  else
    upstream="$range"; branch=""
  fi
  [[ "$branch" == "HEAD" ]] && branch=""

  # "--root" has no upstream: the range is every commit reachable from the branch.
  if [[ "$upstream" == "--root" ]]; then
    root=1; upstream=""
  fi
  local rev_range="${upstream:+${upstream}..}${branch:-HEAD}"

  if ! git diff --quiet || ! git diff --cached --quiet; then
    print -ru2 -- "error: working tree not clean; commit or stash first."
    return 1
  fi

  # Resolve base unix timestamp + UTC offset once.
  # python3.14 by name: zoneinfo must be there, whatever "python3" points at.
  local base_ts offset
  if ! read -r base_ts offset < <(python3.14 - "$base_date" "$tz" <<'PY'
import sys
from datetime import datetime
from zoneinfo import ZoneInfo
dt = datetime.fromisoformat(sys.argv[1]).replace(tzinfo=ZoneInfo(sys.argv[2]))
print(int(dt.timestamp()), dt.strftime("%z"))
PY
  ); then
    print -ru2 -- "error: could not parse base date '$base_date' (tz=$tz)."
    return 1
  fi

  local count
  count=$(git rev-list --count "$rev_range") || return 1
  if [[ "$count" -eq 0 ]]; then
    print -ru2 -- "error: no commits in $rev_range."
    return 1
  fi

  # Prefer the faketime wrapper so signature timestamps track the commit date.
  local gpg_opt=""
  if command -v gpg-faketime >/dev/null 2>&1; then
    gpg_opt="-c gpg.program=gpg-faketime"
  else
    print -ru2 -- "note: gpg-faketime not found; signing with plain gpg (signature time = now)."
  fi

  print -r -- "Rewriting $count commit(s) in ${root:+--root }$rev_range:"
  print -r -- "  dates from $base_date ($tz), +${interval}s each, GPG-signed."
  if ! read -q "?Proceed? [y/N] "; then print; return 1; fi
  print

  local git_dir; git_dir=$(git rev-parse --absolute-git-dir)
  local counter_file="$git_dir/retime-counter"
  local helper="$git_dir/retime-step.sh"
  print -r -- 0 > "$counter_file"

  # Constants are baked in as literals so `git rebase --continue` still works.
  cat > "$helper" <<EOF
#!/bin/sh
n=\$(cat "$counter_file")
d="\$(( $base_ts + \$n * $interval )) $offset"
GIT_COMMITTER_DATE="\$d" git $gpg_opt commit --amend --no-edit --date="\$d" -S --no-verify
echo \$(( \$n + 1 )) > "$counter_file"
EOF

  local -a rb_args
  rb_args=(--exec "sh ${(q)helper}")
  if [[ -n "$root" ]]; then
    rb_args+=(--root)
  else
    rb_args+=("$upstream")
  fi
  [[ -n "$branch" ]] && rb_args+=("$branch")

  git rebase "${rb_args[@]}"
  local rc=$?

  if [[ $rc -eq 0 ]]; then
    rm -f "$counter_file" "$helper"
  else
    print -ru2 -- "rebase stopped (rc=$rc). Resolve, then 'git rebase --continue' (state kept in $git_dir)."
    print -ru2 -- "Or 'git rebase --abort' and rerun."
  fi
  return $rc
}
