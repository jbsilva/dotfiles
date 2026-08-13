#!/usr/bin/env zsh
# Author: Julio Batista Silva
# Copyright: Copyright (c) 2023, Julio Batista Silva
# License: GPL v3
# Email: julio@juliobs.com

# Synology-only. Kept as a readonly-ish local in each function rather than a
# top-level assignment, which exported SYNOSHARE into every shell on every
# platform just by sourcing this file.
_synoshare_bin() { print /usr/syno/sbin/synoshare }

# Mount Synology shares using passwords from Vault
function mount_share()
{
    local usage="$(
	cat <<-EOF
	Mount Synology shares by name using passwords in Vault

	Usage:
	$0 SHARE_NAME...    Mount one or more Synology shares by name

	Examples:
	    $0 SHARE1
	    $0 SHARE1 SHARE2 SHARE3

	Your user needs to have sudo permissions on Synology.
	The vault with the share passwords must be unlocked.

	Report bugs to <julio@juliobs.com>.
	EOF
    )"

    local SYNOSHARE="$(_synoshare_bin)"

    # Check synoshare
    if [[ ! -e $SYNOSHARE ]]; then
        print "Could not find synoshare" >&2
        return 1
    fi

    # Check for vault
    if (( ! $+commands[vault] )); then
        print "Could not find vault" >&2
        return 1
    fi

    # Need at least one share name
    if (( $# < 1 )); then
        print "$usage" >&2
        return 1
    fi

    # Mount each share with password from Vault. Requires sudo
    local SHARE
    for SHARE in "$@"; do
        print "Mounting $SHARE" >&2
        sudo $SYNOSHARE --enc_mount $SHARE \
            "$(vault kv get -mount=kv -field=pw $SHARE)"
    done
}


# Unmount
function unmount_share()
{
    local SYNOSHARE="$(_synoshare_bin)"
    sudo "$SYNOSHARE" --enc_unmount "$@"
}

# Unmount all decripted shares
function unmount_all_shares()
{
    local SYNOSHARE="$(_synoshare_bin)"
    local SHARES
    SHARES="$(sudo "${SYNOSHARE}" --enum DEC | sed '1,2d;:a;N;$!ba;s/\n/ /g')"
    print "Unmounting ${SHARES}"
    print -r -- ${SHARES} | xargs sudo "$SYNOSHARE" --enc_unmount
}
