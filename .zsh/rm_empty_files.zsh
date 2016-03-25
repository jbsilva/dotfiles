#!/usr/bin/env zsh
# Remove empty files.
# Requires GNU find
function rm_empty_files()
{
    local DIR="${1:-'.'}"
    find . -size 0 -delete
}
