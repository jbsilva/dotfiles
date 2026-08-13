#!/usr/bin/env bash
#
# Run scripts/shell-selftest.zsh against the platforms this repo targets but
# this MacBook cannot be: Ubuntu/WSL, Synology DSM, and a bare Linux with no
# zsh plugins installed at all.
#
# The DSM case is an approximation, not a real DSM image: Synology does not
# publish one. It reproduces what .zshrc actually keys off -- /etc/synoinfo.conf
# for detection and /opt (Entware) for paths -- which is what matters here.
#
# Usage:
#   scripts/test-shell-docker.sh            # all scenarios
#   scripts/test-shell-docker.sh wsl        # just one

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! docker info >/dev/null 2>&1; then
  echo "docker is not running. On this machine: colima start" >&2
  exit 1
fi

# Mount the config read-only so a container can never write into the repo.
docker_common=(
  --rm
  -v "$repo_root/.zshrc:/root/.zshrc:ro"
  -v "$repo_root/.zsh:/root/.zsh:ro"
  -v "$repo_root/scripts/shell-selftest.zsh:/selftest.zsh:ro"
  # The precmd/preexec title hooks emit escape codes that mangle CI output.
  -e DOTFILES_DISABLE_AUTO_TITLE=1
)

failures=0

run_scenario() {
  local name="$1" image="$2" expect="$3" setup="$4"
  shift 4
  # macOS ships bash 3.2, where "${arr[@]}" on an empty array trips `set -u`.
  local -a extra_env=()
  (( $# )) && extra_env=("$@")

  echo
  echo "==============================================================="
  echo "  $name  ($image)"
  echo "==============================================================="

  if docker run "${docker_common[@]}" ${extra_env[@]+"${extra_env[@]}"} "$image" bash -c "
    set -e
    export DEBIAN_FRONTEND=noninteractive
    $setup
    zsh -i /selftest.zsh '$expect'
  "; then
    echo "--> $name PASSED"
  else
    echo "--> $name FAILED"
    failures=$((failures + 1))
  fi
}

# ---------------------------------------------------------------------------
# Ubuntu 26.04 as WSL, with the plugins Debian packages
# ---------------------------------------------------------------------------
scenario_wsl() {
  # SC2016: the setup string is executed by bash *inside the container*, so
  # $PATH must stay unexpanded here. Single quotes are deliberate.
  # shellcheck disable=SC2016
  run_scenario "WSL (Ubuntu 26.04)" "ubuntu:26.04" "wsl" '
    apt-get update -qq >/dev/null
    apt-get install -y -qq zsh zsh-autosuggestions zsh-syntax-highlighting >/dev/null
    mkdir -p /mnt/c/Windows/System32 /mnt/c/Users
    # Windows PATH leakage is the thing zshrc_wsl has to clean up.
    export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Program Files/nodejs"
  ' -e WSL_DISTRO_NAME=Ubuntu
}

# ---------------------------------------------------------------------------
# Synology DSM + Entware
# ---------------------------------------------------------------------------
scenario_synology() {
  run_scenario "Synology DSM (simulated)" "debian:stable-slim" "synology" '
    apt-get update -qq >/dev/null
    apt-get install -y -qq zsh >/dev/null
    touch /etc/synoinfo.conf
    mkdir -p /opt/bin /opt/sbin /opt/share/terminfo /volume1/docker
    echo Europe/Berlin > /etc/TZ
  '
}

# ---------------------------------------------------------------------------
# Bare Linux, no plugins at all -- the shell must still come up clean
# ---------------------------------------------------------------------------
scenario_bare() {
  run_scenario "Bare Linux (no plugins)" "debian:stable-slim" "linux" '
    apt-get update -qq >/dev/null
    apt-get install -y -qq zsh >/dev/null
  '
}

case "${1:-all}" in
  wsl)      scenario_wsl ;;
  synology) scenario_synology ;;
  bare)     scenario_bare ;;
  all)      scenario_wsl; scenario_synology; scenario_bare ;;
  *)        echo "unknown scenario: $1 (wsl|synology|bare|all)" >&2; exit 2 ;;
esac

echo
if (( failures )); then
  echo "$failures scenario(s) FAILED"
  exit 1
fi
echo "All scenarios passed."
