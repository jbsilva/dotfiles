# Clone directories
function clone_dir()
{

    if (( ! $+commands[rsync] )); then
        return 1
    fi

    cleand $DIR

    local ORIGEM="${1:-'.'}"
    local DESTINO="${2}"
    rsync -aruv --delete "$ORIGEM" "$DESTINO"
}
