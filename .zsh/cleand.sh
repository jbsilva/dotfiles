#!/usr/bin/env zsh
# Removes .DS_Store, Thumbs.db and desktop.ini from all tree
function cleand()
{
    local DIR="${1:-$PWD}"

    if [[ "$OSTYPE" == darwin* ]]; then
        dot_clean -m --keep=mostrecent $DIR
    fi
    
    find $DIR -type f \( -name '.DS_Store' -o -name 'Thumbs.db' -o -name 'desktop.ini' \) -exec echo "{}" \; -exec rm "{}" \;
}
