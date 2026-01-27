#!/usr/bin/env zsh
# Removes common junk files/dirs from a directory tree (.DS_Store, Thumbs.db, desktop.ini, Icon?, @eaDir).
# On macOS, also runs dot_clean when available.
function cleand()
{
    local DIR="${1:-$PWD}"

    if [[ "$OSTYPE" == darwin* ]] && (( $+commands[dot_clean] )); then
        dot_clean -m --keep=mostrecent "$DIR"
        #xattr -rc $DIR
    fi

    find "$DIR" \
        \( \
            -type f \( -name '.DS_Store' -o -name 'Thumbs.db' -o -iname 'desktop.ini' -o -name 'Icon?' \) \
            -o -type d -name '@eaDir' \
        \) \
        -print -exec rm -rf {} +
}
