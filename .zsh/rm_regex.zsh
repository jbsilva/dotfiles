#!/usr/bin/env zsh
# Removes all files matching the regex pattern
# Example: rm_regex ".*/[0-9].*\.txt"
function rm_regex()
{
    find . -maxdepth 1 -type f -regextype sed -regex $1 -exec rm -i "{}" \;
}
