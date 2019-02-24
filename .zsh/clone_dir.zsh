#!/usr/bin/env zsh
# Author: Julio Batista Silva"
# Copyright: Copyright (c) 2015, Julio Batista Silva
# License: GPL v3
# Email: julio@juliobs.com

# Clone directories. Rsync wrapper
function clone_dir()
{

    local usage="$(
cat <<EOF
Usage:
        $0 [-OPTION] [SRC] [DEST]           Clones SRC in DEST
        $0 [-OPTION] [DEST]                 Clones current directory in DEST

Options:
        -c, --clean                         Clean directory before cloning

Examples:
        $0 -c ~/My_Dir julio@juliobs.com:~/www/files/
        $0 -c ~/Docs/ ~/nfs/ ~/Docs/rsync_exclude.txt
        $0 ~/Docs 10.0.0.1::backup ~/Docs/rsync_exclude.txt

Report bugs to <julio@juliobs.com>.
EOF
    )"


    if (( ! $+commands[rsync] )); then
        print "You need to install rsync" >&2
        return 1
    fi


    args=()
    args+=(--recursive)         # Copy directories recursively
    args+=(--links)             # Copy symlinks as symlinks
    args+=(--perms)             # Preserve permissions
    args+=(--owner)             # Preserve owner
    args+=(--group)             # Preserve group
    args+=(--times)             # Transfer/update modification times
    args+=(--devices)           # Transfer character and block device files
    args+=(--specials)          # Transfer special files such as named sockets and fifos
    args+=(--delete)            # Delete files not SRC
    #args+=(--whole-file)        # Don't use delta-xfer algorithm
    args+=(--compress-level=0)  # No compression
    args+=(--no-inc-recursive)  # Disable incremental recursion for better estimate (uses more memory)
    args+=(--info=progress2)    # Show total progress
    args+=(--human-readable)    # Output numbers in a more human-readable format
    #args+=(--ignore-existing)   # Ignore existing
    #args+=(--size-only)         # Don't compare change date
    #args+=(--preallocate)       # Allocate dest files before writing
    #args+=(--progress)          # Show progress during transfer
    #args+=(--verbose)           # Increase verbosity
    #args+=(--compress)          # Compression
    #args+=(--update)            # Update
    #args+=(--inplace)           # Inplace
    #args+=(--partial)           # Partial
    #args+=(--dry-run)           # Dry-run
    #args+=(--rsh="ssh -T -c arcfour -o Compression=no -x") # No SSH compression

    clean=0
    if [[ "$1" == "-c" || "$1" == "--clean" ]]; then
      clean=1
      shift
    fi


    if (( $# == 1 )); then
        local ORIGEM="$PWD"
        local DESTINO="${1}"
    elif (( $# == 2 )); then
        local ORIGEM="${1}"
        local DESTINO="${2}"
    elif (( $# == 3 )); then
        local ORIGEM="${1}"
        local DESTINO="${2}"
        args+=(--exclude-from="${3}")
    else
      print "$usage" >&2
      return 1
    fi


    if (( $clean == 1 )); then
        cleand $ORIGEM
    fi

    print "rsync ${args[*]} \"$ORIGEM\" \"$DESTINO\"" >&2

    # Uses environment variable $SSHPASS for auth if it is set
    if [[ -v SSHPASS ]]; then
        sshpass -e rsync ${args[*]} "$ORIGEM" "$DESTINO"
    else
        rsync ${args[*]} "$ORIGEM" "$DESTINO"
        #find ${ORIGEM} -type f > /tmp/backup.txt
        #cat /tmp/backup.txt | parallel -j 8 rsync ${args[*]} {} "$DESTINO"
    fi
}
