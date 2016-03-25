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
    args+=(--progress)
    args+=(--verbose)
    args+=(--recursive)
    args+=(--links)
    args+=(--perms)
    args+=(--owner)
    args+=(--group)
    args+=(--times)
    args+=(--devices)
    args+=(--specials)
    args+=(--delete)
#    args+=(--compress)
#    args+=(--update)
#    args+=(--inplace)
#    args+=(--partial)


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
    rsync ${args[*]} "$ORIGEM" "$DESTINO"
}
