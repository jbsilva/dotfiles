#!/usr/bin/env python3
"""Turn a Proton account server list into the file gluetun reads.

gluetun carries its own Proton list, and on a paid account that list is a
different set: it holds servers the account does not have, and misses most of
the ones it does. It merges what it finds in /gluetun/servers.json by timestamp
though, so a file built from the account API takes precedence and gluetun can
then choose and fail over among servers that exist.

  proton-to-gluetun.py ACCOUNT_JSON GLUETUN_REFERENCE_JSON OUT_JSON [--timestamp N]

ACCOUNT_JSON is the reply from
https://account.protonvpn.com/api/vpn/v1/logicals?WithIpV6=1
GLUETUN_REFERENCE_JSON is gluetun's own protonvpn.json, used only to learn how
it spells country names.
"""
import argparse
import json
import time

ap = argparse.ArgumentParser()
ap.add_argument("account")
ap.add_argument("reference")
ap.add_argument("out")
ap.add_argument("--timestamp", type=int, default=int(time.time()))
ap.add_argument("--max-tier", type=int, default=2)
ap.add_argument("--countries", default="", help="comma separated ISO codes, empty for all")
ap.add_argument("--p2p-suitable", action="store_true",
                help="keep only servers that forward a port, and drop secure core and Tor")
ap.add_argument("--max-load", type=int, default=100)
args = ap.parse_args()

account = json.load(open(args.account))["LogicalServers"]
ref = json.load(open(args.reference))
ref_servers = ref.get("servers") or []

# gluetun matches SERVER_COUNTRIES on a full country name, which the account API
# gives only as a code. Learn the spelling from the servers both lists know,
# keyed on the exit country: a secure core server enters one country and leaves
# another, so keying on the entry country names it after the wrong one.
# Majority vote, so a single odd entry cannot decide a country.
import collections

by_name = {s.get("server_name"): s for s in ref_servers}
votes = collections.defaultdict(collections.Counter)
for L in account:
    if L.get("Features", 0) & 1:  # secure core, named after the wrong country
        continue
    other = by_name.get(L["Name"])
    if other and other.get("country"):
        votes[L.get("ExitCountry") or L["EntryCountry"]][other["country"]] += 1
code_to_country = {code: c.most_common(1)[0][0] for code, c in votes.items()}

# The overlap does not reach every country, so spell out the ones worth
# filtering on. gluetun's own wording wins where the two disagree.
KNOWN = {
    "NL": "Netherlands", "CH": "Switzerland", "SE": "Sweden", "IS": "Iceland",
    "DE": "Germany", "FR": "France", "ES": "Spain", "IT": "Italy",
    "GB": "UK", "UK": "UK", "IE": "Ireland", "BE": "Belgium", "AT": "Austria",
    "DK": "Denmark", "NO": "Norway", "FI": "Finland", "PL": "Poland",
    "PT": "Portugal", "CZ": "Czechia", "RO": "Romania", "LU": "Luxembourg",
    "US": "United States", "CA": "Canada", "AU": "Australia", "NZ": "New Zealand",
    "JP": "Japan", "SG": "Singapore", "HK": "Hong Kong", "BR": "Brazil",
}
for code, name in KNOWN.items():
    code_to_country.setdefault(code, name)

# Proton's feature bitmask. Secure core enters one country and leaves another,
# which halves throughput, and a Tor server rewrites the exit entirely. Neither
# suits a service that needs a forwarded port.
SECURE_CORE, TOR, P2P, STREAMING = 1, 2, 4, 8
servers, skipped = [], 0

wanted = {c.strip().upper() for c in args.countries.split(",") if c.strip()}

for L in account:
    if L.get("Status") != 1 or L.get("Tier", 0) > args.max_tier:
        skipped += 1
        continue
    features = L.get("Features", 0)
    code = L.get("ExitCountry") or L.get("EntryCountry")
    if wanted and code not in wanted:
        skipped += 1
        continue
    if args.p2p_suitable and (
        not features & P2P or features & SECURE_CORE or features & TOR
    ):
        skipped += 1
        continue
    if L.get("Load", 0) > args.max_load:
        skipped += 1
        continue
    for phys in L.get("Servers", []):
        if phys.get("Status") != 1:
            continue
        key = phys.get("X25519PublicKey")
        entry = phys.get("EntryIP")
        if not key or not entry:
            continue
        servers.append({
            "vpn": "wireguard",
            "country": code_to_country.get(L.get("ExitCountry") or L["EntryCountry"], L.get("ExitCountry") or L["EntryCountry"]),
            "city": L.get("City") or "",
            "server_name": L["Name"],
            "hostname": phys.get("Domain", ""),
            "wgpubkey": key,
            "stream": bool(features & STREAMING),
            "port_forward": bool(features & P2P),
            "ips": [entry],
        })

out = {
    "version": 1,
    "protonvpn": {
        "version": ref.get("version", 4),
        "timestamp": args.timestamp,
        "servers": servers,
    },
}
json.dump(out, open(args.out, "w"))

named = sum(1 for s in servers if not (len(s["country"]) == 2 and s["country"].isupper()))
print("servers written        %d" % len(servers))
print("  with port forwarding %d" % sum(1 for s in servers if s["port_forward"]))
print("  country named        %d of %d" % (named, len(servers)))
print("  logical skipped      %d (down, or above tier %d)" % (skipped, args.max_tier))
print("timestamp              %d" % args.timestamp)
