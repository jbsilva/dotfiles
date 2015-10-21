# Downloads directories recursively. Mirror remote.
# `baixa_dir $url $cut_dirs $level`
# Example with login: http://my_username:my_password@files.juliobs.com/Images/
function baixa_dir()
{
    if (( ! $+commands[wget] )); then
        return 1
    fi

    local CUT_DIRS="${2:-0}"
    local LEVEL="${3:-5}"
    local UserAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36'

    wget -e robots=off \
        --continue \
        --timestamping \
        --user-agent="${UserAgent}" \
        --cut-dirs=${CUT_DIRS} \
        --no-parent \
        --recursive \
        --relative \
        --level=${LEVEL} \
        --no-host-directories \
        --no-check-certificate \
        --reject="index.html*" \
        --append-output=wget_log.txt \
        --verbose \
        "$1"
}
