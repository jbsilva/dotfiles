#!/usr/bin/env zsh
#
# Assertions run inside an interactive zsh that has already sourced ~/.zshrc.
# Used by scripts/test-shell-docker.sh to check the shell config on platforms
# that are not this MacBook (WSL, Synology DSM, plain Linux).
#
# Exits non-zero if any required check fails. Checks that depend on optional
# packages report as "skip" rather than failing, because the whole point of the
# portable plugin loader is that a machine with none of them still works.

emulate -L zsh
setopt no_unset

typeset -i failures=0

pass() { print -r -- "  ok    $1" }
fail() { print -r -- "  FAIL  $1"; (( failures++ )) }
skip() { print -r -- "  skip  $1" }

expect_platform="${1:-}"

print -r -- "--- platform ---"
if [[ -n $expect_platform ]]; then
  if [[ $DOTFILES_PLATFORM == $expect_platform ]]; then
    pass "DOTFILES_PLATFORM = $DOTFILES_PLATFORM"
  else
    fail "DOTFILES_PLATFORM = ${DOTFILES_PLATFORM:-<unset>}, expected $expect_platform"
  fi
else
  pass "DOTFILES_PLATFORM = ${DOTFILES_PLATFORM:-<unset>}"
fi

print -r -- "--- functions defined by .zshrc ---"
for fn in extract bd addToPathStart addToPathEnd; do
  (( $+functions[$fn] )) && pass "$fn" || fail "$fn is not defined"
done

print -r -- "--- helper files in ~/.zsh were sourced ---"
for fn in rotate_video getuti rm_empty_dirs py_server; do
  (( $+functions[$fn] )) && pass "$fn" || fail "$fn is not defined"
done

print -r -- "--- zle widgets ---"
(( $+widgets[edit-command-line] )) && pass "edit-command-line" \
  || fail "edit-command-line widget missing"

print -r -- "--- optional plugins (skip = not installed on this image) ---"
(( $+functions[_zsh_autosuggest_start] )) && pass "zsh-autosuggestions" \
  || skip "zsh-autosuggestions not installed"
(( $+functions[_zsh_highlight] )) && pass "zsh-syntax-highlighting" \
  || skip "zsh-syntax-highlighting not installed"
(( $+widgets[history-substring-search-up] )) && pass "history-substring-search" \
  || skip "zsh-history-substring-search not installed"

print -r -- "--- no zplug anywhere ---"
if (( $+functions[zplug] )) || [[ -n ${ZPLUG_HOME:-} ]]; then
  fail "zplug is still being loaded"
else
  pass "zplug is gone"
fi

print -r -- "--- a fresh interactive shell starts silently ---"
# Every check above asks "is this defined", which a shell that printed three
# errors on the way up still answers yes to. This catches the errors: a clean
# start writes nothing to stderr. Run as a child so the assertion is about a
# shell starting from scratch, not the one already running this script.
#
# This only holds in the container images, which is the only place this script
# runs. On the Mac, `fzf --zsh` restores the full option list through `eval`,
# and `zle` cannot be set without a terminal, so a tty-less start there prints
# "can't change option: zle" twice from inside fzf's own integration. A real
# terminal never sees it.
typeset startup_stderr
startup_stderr="$(zsh -i -c exit 2>&1 >/dev/null)"
if [[ -z $startup_stderr ]]; then
  pass "no output on stderr during startup"
else
  fail "startup wrote to stderr:"
  print -r -- "$startup_stderr" | sed 's/^/          | /'
fi

print -r -- "--- \$PATH is de-duplicated ---"
typeset -i dupes
dupes=$(print -rl -- $path | sort | uniq -d | wc -l)
(( dupes == 0 )) && pass "no duplicate PATH entries" \
  || fail "$dupes duplicate PATH entries"

case $DOTFILES_PLATFORM in
synology)
  print -r -- "--- synology ---"
  [[ -n ${SYNO_VOLUME:-} ]] && pass "SYNO_VOLUME=$SYNO_VOLUME" || fail "SYNO_VOLUME unset"
  (( $+aliases[syno-services] )) && pass "DSM aliases" || fail "DSM aliases missing"
  if [[ -d /opt/bin ]]; then
    [[ $path[1] == /opt/bin ]] && pass "/opt/bin is first in PATH" \
      || fail "/opt/bin is not first in PATH (got $path[1])"
    [[ ${TERMINFO:-} == /opt/share/terminfo ]] && pass "TERMINFO points at Entware" \
      || skip "Entware terminfo not present"
  else
    skip "Entware (/opt/bin) not present"
  fi
  ;;
wsl)
  print -r -- "--- wsl ---"
  (( $+aliases[explorer] )) && pass "interop aliases" || fail "interop aliases missing"
  # Windows PATH entries must have been stripped, except the allowed ones.
  typeset -i bad
  bad=0
  for d in $path; do
    case $d in
      /mnt/c/Windows|/mnt/c/Windows/System32) ;;
      /mnt/*) (( bad++ )) ;;
    esac
  done
  (( bad == 0 )) && pass "stray Windows PATH entries removed" \
    || fail "$bad Windows PATH entries left in \$PATH"
  ;;
esac

print -r -- ""
if (( failures )); then
  print -r -- "FAILED: $failures check(s)"
  exit 1
fi
print -r -- "All checks passed."
