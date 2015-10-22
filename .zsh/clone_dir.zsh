#!/usr/bin/env zsh

# Clone directories
function clone_dir()
{

    local usage="$(
    cat <<EOF
Uso:
Clona a pasta ORIGEM em DESTINO:  $0 ORIGEM DESTINO
Clona diretório atual em DESTINO: $0 DESTINO

EOF
    )"


    if (( ! $+commands[rsync] )); then
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
    args+=(--update)
    args+=(--delete)


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


    cleand $ORIGEM


    rsync ${args[*]} "$ORIGEM" "$DESTINO"
}
