#!/usr/bin/env zsh
# Serve the current directory over HTTP and open it in a browser.
function py_server()
{
    local port="${1:-8000}"
    local url="http://localhost:${port}/"

    # `open` on macOS, `xdg-open` elsewhere. Backgrounded with a short delay so
    # the browser does not race the server's startup.
    if (( $+commands[open] )); then
        ( sleep 1 && open "$url" ) &!
    elif (( $+commands[xdg-open] )); then
        ( sleep 1 && xdg-open "$url" ) &!
    fi

    python3 -m http.server "$port"
}
