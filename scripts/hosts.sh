#!/bin/bash
# Run as root
curl --output /etc/hosts --url "https://someonewhocares.org/hosts/zero/hosts"

echo "
###############################################################################
#<Local>
127.0.1.1	MeuPC.localdomain	MeuPC
#</Local>
###############################################################################" >> /etc/hosts
