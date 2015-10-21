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


    if (( $# == 1 )); then
        local ORIGEM="$PWD"
        local DESTINO="${1}"
    elif (( $# == 2 )); then
        local ORIGEM="${1}"
        local DESTINO="${2}"
    else
      print "$usage" >&2
      return 1
    fi

    cleand $ORIGEM

    rsync --progress \
        --verbose \
        --recursive \
        --links \
        --perms \
        --owner \
        --group \
        --times \
        --devices \
        --specials \
        --update \
        --delete "$ORIGEM" "$DESTINO"
}
