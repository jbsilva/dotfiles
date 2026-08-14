#!/usr/bin/env bash
#
# Replace /etc/hosts with the someonewhocares.org ad/tracker blocklist, keeping
# a local section for this machine's own names.
#
# Run as root:
#   sudo scripts/hosts.sh
#
# The previous generation is kept as /etc/hosts.bak. To undo:
#   sudo mv /etc/hosts.bak /etc/hosts

set -euo pipefail

url="https://someonewhocares.org/hosts/zero/hosts"
hostname_short="$(hostname -s)"

if [ "$(id -u)" -ne 0 ]; then
  echo "hosts.sh: must run as root (try: sudo $0)" >&2
  exit 1
fi

# Download to a temporary file first. `curl --output /etc/hosts` writes whatever
# comes back, so a 502 or a captive portal would land in /etc/hosts as the new
# contents -- and losing name resolution is not a failure you want to debug
# without a working /etc/hosts.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "hosts.sh: fetching $url"
if ! curl --fail --silent --show-error --location --max-time 60 --output "$tmp" --url "$url"; then
  echo "hosts.sh: download failed; /etc/hosts left untouched" >&2
  exit 1
fi

# A truncated download is still a 200. The real file is ~19k lines; anything
# under a few hundred means something went wrong upstream.
lines="$(wc -l < "$tmp")"
if [ "$lines" -lt 100 ]; then
  echo "hosts.sh: downloaded file has only $lines lines, refusing to install it" >&2
  exit 1
fi

# localhost has to resolve, or the machine is broken in ways far worse than
# having ads.
if ! grep -qE '^127\.0\.0\.1[[:space:]]+localhost' "$tmp"; then
  echo "hosts.sh: downloaded file has no localhost entry, refusing to install it" >&2
  exit 1
fi

cat >> "$tmp" <<EOF

###############################################################################
#<Local>
127.0.1.1	${hostname_short}.localdomain	${hostname_short}
#</Local>
###############################################################################
EOF

if [ -f /etc/hosts ]; then
  cp /etc/hosts /etc/hosts.bak
  echo "hosts.sh: previous /etc/hosts saved to /etc/hosts.bak"
fi

install -m 0644 "$tmp" /etc/hosts
echo "hosts.sh: installed $lines blocklist entries for $hostname_short"
