#!/usr/bin/env zsh
# Remove empty files under a directory (default: the current one).
function rm_empty_files()
{
    local DIR="${1:-.}"
    if [[ ! -d $DIR ]]; then
        print "rm_empty_files: not a directory: $DIR" >&2
        return 1
    fi
    find "$DIR" -type f -size 0 -delete
}
