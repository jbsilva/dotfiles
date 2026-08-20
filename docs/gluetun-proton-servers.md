# Choosing a Proton server for gluetun

gluetun can pick a Proton server for you from a list it carries inside the image. On a paid account
that list is the wrong one, and the way it fails is quiet enough to cost days.

Give gluetun the server instead, out of a profile downloaded from the account page.

## The list in the image is not your list

Compare the servers an account holds against the list gluetun ships:

```
account   2337 servers
gluetun    733
in both    337        only 14% of the account
only account 2000
only gluetun  396     servers the account does not have
```

The image was current, built five days before the comparison. This is not a stale copy of the same
data, it is a different set, and it looks like the view an unauthenticated caller gets. The same
list is published at
[qdm12/gluetun-servers](https://github.com/qdm12/gluetun-servers/blob/main/pkg/servers/protonvpn.json),
which is useful for confirming what gluetun believes without starting it.

The list also carries no load figure, so `SERVER_COUNTRIES` cannot avoid a busy server even when it
picks a real one.

## What a retired server does

A server that gluetun lists and the account does not still answers. It completes the WireGuard
handshake, routes traffic at full speed, and reports a sensible exit country. Only port forwarding
is dead:

```
ERROR [port forwarding] adding port mapping: ... read udp 10.2.0.2:48879->10.2.0.1:5351:
recvfrom: connection refused
```

gluetun drops its own firewall rule between a failed renewal and the next good one, so the inbound
port closes:

```
22:11:34  firewall opens the port
22:12:19  firewall REMOVES it        closed
22:14:59  opens again                closed for 2m40s
22:19:18  opens                      closed for 3m25s
```

The port stays shut roughly two thirds of the time. A one-shot port checker still reports it open,
because it asks during one of the good windows, while anything that checks repeatedly reports it
unreachable. Watch for that disagreement: it means intermittent, not closed.

## Pick the server yourself

The account page at `account.protonvpn.com/downloads` shows every server with its load and marks the
ones that forward a port. Download a WireGuard profile for the one you want, then take three values
from it:

```ini
[Interface]
PrivateKey = ...
Address    = 10.2.0.2/32

[Peer]
PublicKey = ...
Endpoint  = 203.0.113.10:51820
```

Those go straight into gluetun, which then chooses nothing:

```yaml
VPN_SERVICE_PROVIDER: custom
VPN_TYPE: wireguard
VPN_ENDPOINT_IP: 203.0.113.10
VPN_ENDPOINT_PORT: 51820
WIREGUARD_PUBLIC_KEY: ...
WIREGUARD_PRIVATE_KEY: ...
WIREGUARD_ADDRESSES: 10.2.0.2/32
VPN_PORT_FORWARDING: "on"
VPN_PORT_FORWARDING_PROVIDER: protonvpn
```

A custom provider has no port forwarding of its own, which is why the provider is named again on the
last line.

A Proton key belongs to the account rather than to one server, so any profile's key reaches any
server. Keep several profiles and switch by rewriting those values.

## Checking a server still exists

The account API answers with the servers the account really has, and with their load. Take the
session from a logged-in browser on the downloads page:

```sh
curl -H 'x-pm-uid: <uid>' -b '<session cookies>' \
  'https://account.protonvpn.com/api/vpn/v1/logicals?WithIpV6=1' > servers.json

jq -r '.LogicalServers[] | select(.Name=="NL#428") | "\(.Name) load=\(.Load)%"' servers.json
```

Treat that output as a credential while it lives on disk.

## The updater does not close the gap

gluetun can refresh its own list, and it writes the image's copy either way:

```sh
docker run --rm -v /tmp/g:/gluetun --entrypoint /bin/sh qmcgaw/gluetun:latest \
  -c '/gluetun-entrypoint update -providers protonvpn'
```

Refreshing from Proton needs account credentials:

```
WARN getting protonvpn servers: credentials are missing: email is empty - skipping update
INFO writing servers data files to /gluetun/servers/ with 26611 hardcoded servers
```

The updater has no field for a one-time code, so an account with two-factor authentication cannot
use it, and the failure reads the same as a wrong password
([qdm12/gluetun#3440](https://github.com/qdm12/gluetun/issues/3440)). Naming the endpoint yourself
avoids the whole question.

## The exit address is not the one in the profile

Whatever address a service authorizes has to be the measured one, not the `Endpoint` in the profile
and not `ExitIP` from the API. Across four servers those three values disagreed every time, usually
inside the same `/24` but once in a different `/8` altogether. Read it from inside the tunnel:

```sh
sudo docker exec <container-on-the-tunnel> curl -s https://ipinfo.io/ip
```
