###############################################################################
#                                   .zshenv
#
# Read by every zsh, before .zshrc and before the terminal is set up. Keep it
# small and side-effect free: scripts and cron shells run it too. On the Nix
# machines it is not symlinked -- nix-darwin reads it into
# `programs.zsh.envExtra`. See "New machine" in README.md.
###############################################################################

# terminfo search path.
#
# Has to be here: ncurses caches the path at the first lookup, which zsh makes
# while setting up the terminal, before .zshrc is read. A $TERM with no entry
# costs the whole line editor, not just colours -- ZLE never starts, so there is
# no backspace and no ^L. Ghostty over SSH is the usual way to hit it; dropping
# the entry into ~/.terminfo on the far host then fixes it without root:
#
#   ssh HOST mkdir -p .terminfo/x
#   scp /Applications/Ghostty.app/Contents/Resources/terminfo/78/xterm-ghostty \
#       HOST:.terminfo/x/xterm-ghostty
#
# ncurses is meant to search ~/.terminfo unasked, but --disable-home-terminfo
# builds do not, and DSM's zsh-static is one. .zshrc still falls back to
# xterm-256color if the entry is missing everywhere.

# Guarded because nested shells inherit the exported value.
if [[ ":${TERMINFO_DIRS}:" != *":$HOME/.terminfo:"* ]]; then
  _terminfo_dirs="$HOME/.terminfo"

  # A Nix profile carries its own database, and zsh does not look there by
  # default. ghostty.terminfo puts xterm-ghostty here, so the machines with Nix
  # need nothing in ~/.terminfo at all.
  [[ -d $HOME/.nix-profile/share/terminfo ]] &&
    _terminfo_dirs="$_terminfo_dirs:$HOME/.nix-profile/share/terminfo"

  [[ -d /opt/share/terminfo ]] && _terminfo_dirs="$_terminfo_dirs:/opt/share/terminfo"

  # Trailing colon keeps ncurses' compiled-in directory on the path. Braces
  # swallow "can't find terminal definition": $TERMINFO_DIRS is special, so
  # assigning redoes terminal setup, which is the point but is noisy on stderr
  # when the entry is still missing.
  { export TERMINFO_DIRS="$_terminfo_dirs:${TERMINFO_DIRS:+$TERMINFO_DIRS:}" } 2>/dev/null

  unset _terminfo_dirs
fi
