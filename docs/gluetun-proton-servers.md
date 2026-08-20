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

## Give gluetun your own list

gluetun merges `/gluetun/servers.json` by timestamp and keeps whichever side is newer, for the whole
provider rather than server by server. A file built from the account API therefore replaces its list
outright, and it then chooses and fails over among servers that exist. Ask for one it no longer has
and it stops with the choices it does have, which is a loud failure rather than a quiet one:

```
ERROR VPN settings: the server name specified is not valid: none of nl#943 is one of
the choices available CH#1031, CH#1131, CH#450, CH#650, CH#801, ...
```

`scripts/proton-to-gluetun.py` does the conversion. There is no reason to carry all 2758 servers, so
filter to the ones worth using:

```sh
scripts/proton-to-gluetun.py account.json gluetun-protonvpn.json servers.json \
  --countries NL,CH,IS,SE --p2p-suitable --max-load 60
```

Then drop it in the gluetun volume and leave `SERVER_NAMES` empty so gluetun may use any of them:

```yaml
VPN_SERVICE_PROVIDER: protonvpn
VPN_TYPE: wireguard
WIREGUARD_PRIVATE_KEY: ...     # any profile's key reaches any server
WIREGUARD_ADDRESSES: 10.2.0.2/32
PORT_FORWARD_ONLY: "on"
VPN_PORT_FORWARDING: "on"
```

Naming a few servers in `SERVER_NAMES` narrows it further, which is what a service that authorizes
an address wants, at the cost of somewhere to fail over to.

## Not every server suits a forwarded port

Proton marks each server with a feature bitmask, and three of the bits decide whether it is worth
using:

| bit | meaning     | keep it?                                          |
| --- | ----------- | ------------------------------------------------- |
| 1   | secure core | no, it enters one country and leaves another      |
| 2   | Tor         | no, it rewrites the exit                          |
| 4   | P2P         | yes, this is the one that carries port forwarding |

`--p2p-suitable` applies all three. The P2P bit matches gluetun's own `port_forward` field on every
one of the 337 servers both lists know, so the mapping is not a guess.

Load is worth filtering on too, and it is the figure gluetun has no access to. On one account every
Icelandic server sat above 62% while the Dutch ones were in the mid forties, so `--max-load 60`
dropped a whole country without naming it.

## Measure before settling on one

Load is a starting point, not an answer. Latency and throughput through the tunnel, taken from one
account across four servers:

| country     | rtt   | throughput |
| ----------- | ----- | ---------- |
| Netherlands | 13 ms | 48 MB/s    |
| Switzerland | 17 ms | 50 MB/s    |
| Sweden      | 26 ms | 41 MB/s    |
| Sweden      | 33 ms | 34 MB/s    |

Proton drops ICMP, so take the round trip from a TCP handshake instead:

```sh
sudo docker exec <container-on-the-tunnel> \
  curl -s -o /dev/null -w '%{time_connect}\n' https://1.1.1.1
```

Stop whatever runs behind the tunnel before cycling gluetun to test it. Recreating the stack for
each attempt makes every dependent container reload its state, and an application holding thousands
of items pays for that each time.

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
inside the same `/24` but once in a different `/8` altogether.

Worse for anything that authorizes a single address: the exit address moves between connections to
**the same server**. One server gave `.62` on one connect and `.53` on the next, same `/24`. Pinning
a server narrows the range, it does not fix the address. Read it from inside the tunnel:

```sh
sudo docker exec <container-on-the-tunnel> curl -s https://ipinfo.io/ip
```
