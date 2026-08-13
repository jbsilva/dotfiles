#!/usr/bin/env zsh
# Remove files in the current directory matching a regex.
# Example: rm_regex ".*/[0-9].*\\.txt"
#
# -regextype is a GNU find extension; BSD find (macOS) does not have it. The
# findutils package installs GNU find as `gfind`, so prefer that when present.
function rm_regex()
{
    if (( $# != 1 )); then
        print "usage: rm_regex REGEX" >&2
        return 1
    fi

    local find_bin
    if (( $+commands[gfind] )); then
        find_bin=gfind
    elif find --version 2>/dev/null | grep -q GNU; then
        find_bin=find
    else
        print "rm_regex: needs GNU find (install findutils, or use gfind)" >&2
        return 1
    fi

    "$find_bin" . -maxdepth 1 -type f -regextype sed -regex "$1" -exec rm -i {} +
}
