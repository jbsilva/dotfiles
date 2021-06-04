# Python 2
function py2_server()
{
    local port="${1:-8000}"
    if (( $+commands[xdg-open] )); then
        xdg-open "http://localhost:${port}/"
    fi
    python2 -m SimpleHTTPServer "$port"
}

# Python 3
function py_server()
{
    local port="${1:-8000}"
    if (( $+commands[xdg-open] )); then
        xdg-open "http://localhost:${port}/"
    fi
    python3 -m http.server "$port"
}

