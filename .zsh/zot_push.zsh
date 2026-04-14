#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# File:        zot_push.zsh
# Description: Push a local Docker image to a remote Zot registry via SSH tunnel
# Author:      Julio Batista Silva
# Email:       julio@juliobs.com
# Copyright:   Copyright (c) 2026, Julio Batista Silva
# License:     GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
# -----------------------------------------------------------------------------
# Usage:
#   source this file from .zshrc, then call:
#
#   zot-push <server> <image> [--colima-profile <name>] [--local-port <num>]
#            [--remote-port <num>]
#
#   Arguments:
#     server              SSH host to tunnel through (as configured in ~/.ssh/config)
#     image               Local Docker image name and tag (e.g. my-image:latest).
#                         Must not include a registry prefix. If no tag is given,
#                         :latest is appended automatically.
#
#   Options:
#     -h, --help          Show this usage summary and exit
#     --local-port <num>  Local tunnel port (default: 5001). Use a value other
#                         than 5000 to avoid conflicting with macOS AirPlay.
#     --remote-port <num> Remote Zot registry port (default: 5000)
#     --colima-profile    Colima instance name to use as Docker daemon source.
#                         If omitted, the active Docker context is used instead,
#                         which works with Docker Desktop, Rancher Desktop, etc.
#
#   Examples:
#     zot-push my-server my-image:latest
#     zot-push my-server my-image:latest --remote-port 8080
#     zot-push my-server my-image:latest --colima-profile default
#     zot-push my-server my-image:latest --local-port 5050 --remote-port 8080
#
# Dependencies: ssh, skopeo (>= 1.10 for --dest-precompute-digests), nc
#
# Notes:
#   - The remote host must have Zot listening on localhost:<remote-port>. The
#     SSH tunnel maps local-port on this machine to remote-port on the server.
#   - TLS verification is disabled because the SSH tunnel already encrypts
#     traffic and the registry is only exposed on localhost at both ends.
#   - Credentials are cached by skopeo in its default auth file. Subsequent
#     pushes to the same registry reuse cached credentials without prompting.
# -----------------------------------------------------------------------------

zot-push() {
  # Reset to standard zsh options so the function behaves consistently regardless
  # of the user's shell configuration. -L scopes the change to this function.
  emulate -L zsh
  # emulate -L zsh already disables MONITOR in non-interactive mode, but these
  # are set explicitly to document intent and guard against future option changes.
  setopt NO_NOTIFY NO_MONITOR

  # Defined once and referenced everywhere to keep error messages consistent.
  # Update this single line if the function signature ever changes.
  local usage='Usage: zot-push <server> <image> [--colima-profile <name>] [--local-port <num>] [--remote-port <num>] (-h for help)'

  # Parse optional flags before reading positional args.
  # -D removes matched flags from $@, so $1 and $2 are always the clean positional
  # args regardless of where the user placed the flags in the argument list.
  # -E is required to parse flags that appear after positional arguments.
  # Without it, zparseopts stops at the first non-option argument (e.g. server)
  # and never reaches flags like --colima-profile that follow the image name.
  # With -E, unrecognized flags are silently left in $@ rather than causing
  # an error, so we detect them explicitly in the loop below.
  local -A opts
  zparseopts -D -E -A opts -- -colima-profile: -local-port: -remote-port: -help h \
    || { print -P "%F{red}✗ Malformed flag%f\n${usage}" >&2; return 1 }

  # Reject any unrecognized flags left in $@ after parsing.
  # A bare - is also rejected here, which is intentional since it has no
  # meaning in this context. -- is consumed by zparseopts and never reaches
  # this loop.
  local arg
  for arg in "$@"; do
    if [[ ${arg} == -* ]]; then
      print -P "%F{red}✗ Unknown flag: ${arg}%f\n${usage}" >&2
      return 1
    fi
  done

  if (( ${+opts[--help]} || ${+opts[-h]} )); then
    print "zot-push - Push a local Docker image to a remote Zot registry via SSH tunnel"
    print ""
    print "Usage: zot-push <server> <image> [--colima-profile <name>] [--local-port <num>]"
    print "         [--remote-port <num>]"
    print ""
    print "Arguments:"
    print "  server              SSH host (as configured in ~/.ssh/config)"
    print "  image               Local image name and tag. Tag defaults to :latest."
    print "                      Must not include a registry prefix."
    print ""
    print "Options:"
    print "  -h, --help          Show this help and exit"
    print "  --local-port <num>  Local tunnel port (default: 5001)"
    print "  --remote-port <num> Remote Zot registry port (default: 5000)"
    print "  --colima-profile    Colima instance name. If omitted, the active"
    print "                      Docker context is used (Docker Desktop, Rancher, etc.)"
    print ""
    print "Examples:"
    print "  zot-push my-server my-image:latest"
    print "  zot-push my-server my-image:latest --remote-port 8080"
    print "  zot-push my-server my-image:latest --colima-profile default"
    print "  zot-push my-server my-image:latest --local-port 5050 --remote-port 8080"
    return 0
  fi

  if (( $# < 2 )); then
    print -P "%F{red}✗ Missing required arguments%f\n${usage}" >&2
    return 1
  fi
  if (( $# > 2 )); then
    print -P "%F{red}✗ Unexpected extra arguments: ${@[3,-1]}%f\n${usage}" >&2
    return 1
  fi

  local server=$1
  local image=$2
  # $# == 2 does not prevent empty-string args like: zot-push '' my-image
  [[ -n ${server} ]] || { print -P "%F{red}✗ Server name must not be empty%f\n${usage}" >&2; return 1 }
  [[ -n ${image} ]] || { print -P "%F{red}✗ Image name must not be empty%f\n${usage}" >&2; return 1 }
  local -i local_port=${opts[--local-port]:-5001}
  local -i remote_port=${opts[--remote-port]:-5000}
  local colima_profile=${opts[--colima-profile]:-}
  # Initialized to 0 so the TRAPEXIT guard is safe even on early returns,
  # before the background SSH process has been started
  local -i SSH_PID=0
  # Initialized to empty so TRAPEXIT can safely test it even if mktemp has not run
  local docker_host ssh_err=''
  # Timeout derived from these two values: max_attempts x 0.2s = timeout_secs
  # Changing max_attempts automatically updates the timeout message below
  local -i max_attempts=150 attempts=0
  local -i timeout_secs=$(( max_attempts / 5 ))

  # local -i silently coerces non-numeric strings to 0, so we need an explicit
  # range check to catch invalid port values before anything starts
  (( local_port > 0 && local_port < 65536 )) \
    || { print -P "%F{red}✗ Invalid local port: '${opts[--local-port]}' (must be 1-65535)%f" >&2; return 1 }
  (( remote_port > 0 && remote_port < 65536 )) \
    || { print -P "%F{red}✗ Invalid remote port: '${opts[--remote-port]}' (must be 1-65535)%f" >&2; return 1 }

  # Pre-compute display string for messages: show both ports only when they differ.
  local port_info
  if (( local_port == remote_port )); then
    port_info=":${local_port}"
  else
    port_info=" (local:${local_port} -> remote:${remote_port})"
  fi

  # Validate image tag: reject malformed forms, auto-append :latest if absent.
  # Without a tag, skopeo may resolve the reference differently than expected.
  if [[ ${image} == :* ]]; then
    print -P "%F{red}✗ Image name must not start with a colon: ${image}%f" >&2
    return 1
  elif [[ ${image} == *: ]]; then
    print -P "%F{red}✗ Image tag must not be empty: ${image}%f" >&2
    return 1
  elif [[ ${image} != *:* ]]; then
    print -P "%F{blue}ℹ No tag specified, using ${image}:latest%f"
    image="${image}:latest"
  fi

  # Reject image names that include a registry prefix.
  # A registry prefix contains a dot or colon before the first slash
  # (e.g. registry.example.com/my-image or registry:5000/my-image),
  # or starts explicitly with localhost/ (no dot, but clearly a registry).
  # A prefix would silently produce a wrong destination URL in the copy step.
  if [[ ${image} == *.*/* || ${image} == *:*/* || ${image} == localhost/* ]]; then
    print -P "%F{red}✗ Image name must not include a registry prefix: ${image}%f" >&2
    return 1
  fi

  # Check for required tools before starting any background process so that
  # errors are clear and no cleanup is needed if a dependency is missing.
  # skopeo >= 1.10 is required for --dest-precompute-digests used in the copy step.
  # Declared explicitly because zsh for-loops do not create their own scope.
  local cmd
  for cmd (ssh skopeo nc); do
    (( ${+commands[$cmd]} )) \
      || { print -P "%F{red}✗ Required command not found: ${cmd}%f" >&2; return 1 }
  done

  # Resolve the Docker socket using the first available source:
  #   1. --colima-profile flag: constructs the socket path for the named Colima
  #      instance directly, without requiring the docker CLI
  #   2. Active Docker context: portable across Colima, Docker Desktop, Rancher
  #      Desktop, and any runtime that registers a Docker context
  #   3. Standard fallback socket: used when the docker CLI is not installed
  if [[ -n ${colima_profile} ]]; then
    docker_host="unix://${HOME}/.config/colima/${colima_profile}/docker.sock"
  else
    docker_host=$(docker context inspect --format '{{.Endpoints.docker.Host}}' 2>/dev/null)
    # The command can exit 0 with empty output (e.g. a Kubernetes-only context
    # with no Docker endpoint), so fall back if the result is empty too.
    [[ -n ${docker_host} ]] || docker_host='unix:///var/run/docker.sock'
  fi

  # Verify the socket file exists before proceeding.
  # The -S test only applies to unix:// sockets; tcp:// remote daemons cannot
  # be tested this way and are assumed reachable if explicitly specified.
  if [[ ${docker_host} == unix://* ]]; then
    [[ -S ${docker_host#unix://} ]] \
      || { print -P "%F{red}✗ Docker socket not found: ${docker_host#unix://}%f\n  Is the Docker daemon running?" >&2; return 1 }
  fi

  # Show which daemon and profile are in use to make it easy to confirm
  # the right source when multiple Colima instances or contexts are active.
  # ${var:+text} expands to text only when var is non-empty.
  print -P "%F{blue}ℹ Docker daemon: ${docker_host}${colima_profile:+ (colima profile: ${colima_profile})}%f"

  # Verify the image exists in the local Docker daemon before starting the tunnel.
  # Failing here is faster and produces a clearer error than failing mid-push
  # after the tunnel is up and registry login has completed.
  # skopeo inspect supports --daemon-host to target a specific socket directly.
  # Note: --daemon-host expects the full unix:// URI, same as --src-daemon-host.
  print -Pn "%F{yellow}⏳ Checking local image ${image}...%f"
  skopeo inspect --daemon-host "${docker_host}" "docker-daemon:${image}" >/dev/null 2>&1 \
    || { print -P "\n%F{red}✗ Image not found in local Docker daemon: ${image}%f" >&2; return 1 }
  print -P " %F{green}✓%f"

  # Verify the local port is free before starting the tunnel.
  # If the port is already occupied, nc would succeed immediately after SSH starts
  # but connect to the wrong service, causing skopeo to fail with a misleading error.
  # Note: there is an inherent race between this check and SSH binding the port.
  # This window is negligible in practice but cannot be fully eliminated.
  if nc -z localhost ${local_port} 2>/dev/null; then
    print -P "%F{red}✗ Port ${local_port} is already in use on localhost%f" >&2
    return 1
  fi

  # Redirect SSH stderr to a named temp file rather than letting it mix with our output.
  # Using ${TMPDIR:-/tmp} with an explicit template is portable across macOS and Linux.
  # The zot-push. prefix makes the file identifiable in the temp directory when debugging.
  # The contents are shown only on tunnel failure to keep normal output clean.
  ssh_err=$(mktemp "${TMPDIR:-/tmp}/zot-push.XXXXXX") \
    || { print -P "%F{red}✗ Failed to create temporary file%f" >&2; return 1 }

  # Start the SSH tunnel in the background.
  # ExitOnForwardFailure=yes: SSH exits immediately if it cannot bind the local port,
  #   which prevents the poll loop below from hanging indefinitely on a broken tunnel.
  # ConnectTimeout=10: avoids a long wait when the remote host is unreachable.
  ssh -N \
      -L "${local_port}:localhost:${remote_port}" \
      -o ExitOnForwardFailure=yes \
      -o ConnectTimeout=10 \
      "${server}" \
      2>"${ssh_err}" &
  SSH_PID=$!

  # TRAP* functions defined inside a zsh function are automatically scoped to it.
  # They are active only during this function's execution and do not affect the
  # parent shell or any other function.
  #
  # TRAPEXIT runs on every exit path: normal return, error return, or signal.
  # The SSH_PID > 0 guard prevents kill from running on early returns before
  # the tunnel was started. wait reaps the zombie after kill and returns
  # immediately if the process is already dead. The ssh_err guard prevents rm
  # from receiving an empty string if mktemp failed before setting the variable.
  #
  # TRAPINT handles Ctrl+C and TRAPTERM handles SIGTERM (e.g. when the parent
  # shell is killed). Both return non-zero, which causes zsh to propagate the
  # signal and then trigger TRAPEXIT for cleanup.
  TRAPEXIT() {
    (( SSH_PID > 0 )) && { kill ${SSH_PID} 2>/dev/null; wait ${SSH_PID} 2>/dev/null }
    [[ -n ${ssh_err} ]] && rm -f "${ssh_err}"
  }
  TRAPINT()  { return $(( 128 + 2 )) }
  TRAPTERM() { return $(( 128 + 15 )) }

  # Poll until the forwarded port starts accepting connections, printing a dot
  # each iteration so the user can see progress.
  # kill -0 checks SSH liveness without sending a real signal. If SSH has exited
  # early (wrong hostname, auth failure, port conflict), we print its captured
  # stderr and abort rather than polling until the timeout.
  # The attempts counter is a safety net for any unexpected case where SSH stays
  # alive but the port never becomes reachable.
  print -Pn "%F{yellow}⏳ Connecting tunnel to ${server}${port_info}%f"
  until nc -z localhost ${local_port} 2>/dev/null; do
    if ! kill -0 ${SSH_PID} 2>/dev/null; then
      print -P "\n%F{red}✗ SSH tunnel failed:%f" >&2
      [[ -s ${ssh_err} ]] && cat "${ssh_err}" >&2
      return 1
    fi
    if (( ++attempts > max_attempts )); then
      print -P "\n%F{red}✗ Timed out waiting for SSH tunnel after ${timeout_secs}s%f" >&2
      return 1
    fi
    print -Pn "%F{yellow}.%f"
    sleep 0.2
  done
  print -P " %F{green}✓%f"

  # Authenticate with the Zot registry exposed through the tunnel.
  # TLS verification is disabled because the SSH tunnel already encrypts the
  # connection and the registry is accessed over localhost only.
  # skopeo login output is intentionally not redirected: it may prompt
  # interactively for credentials and should communicate directly with the user.
  print -P "%F{yellow}⏳ Logging in to registry at localhost:${local_port}...%f"
  skopeo login --tls-verify=false "localhost:${local_port}" \
    || { print -P "%F{red}✗ Registry login failed%f" >&2; return 1 }

  # Copy the image from the local Docker daemon to the remote Zot registry.
  # --src-daemon-host:         socket of the local Docker daemon resolved above
  # --dest-tls-verify=false:   same reasoning as skopeo login above
  # --dest-precompute-digests: precomputes digests before upload so that layers
  #                            already present on the destination are skipped,
  #                            avoiding redundant uploads. Layers with initially
  #                            unknown digests (e.g. compressed on the fly) are
  #                            temporarily streamed to disk. Requires skopeo >= 1.10.
  print -P "%F{yellow}⏳ Pushing ${image} to ${server}${port_info}...%f"
  skopeo copy \
    --src-daemon-host "${docker_host}" \
    --dest-tls-verify=false \
    --dest-precompute-digests \
    "docker-daemon:${image}" \
    "docker://localhost:${local_port}/${image}" \
    || { print -P "%F{red}✗ Image push failed%f" >&2; return 1 }

  # Close the tunnel immediately; TRAPEXIT is kept as a safety net for error paths.
  kill ${SSH_PID} 2>/dev/null
  wait ${SSH_PID} 2>/dev/null
  SSH_PID=0

  print -P "%F{green}✓ Pushed ${image} to ${server}${port_info}%f"
}
