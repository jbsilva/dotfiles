#!/bin/bash
# Run as root
curl --output /etc/hosts --url "http://someonewhocares.org/hosts/zero/hosts"

echo "
###############################################################################
#<Adobe>
0.0.0.0	3dns-2.adobe.com
0.0.0.0	3dns-3.adobe.com
0.0.0.0	activate-sea.adobe.com
0.0.0.0	activate-sjc0.adobe.com
0.0.0.0	activate.adobe.com
0.0.0.0	activate.wip3.adobe.com
0.0.0.0	adobe-dns-2.adobe.com
0.0.0.0	adobe-dns-3.adobe.com
0.0.0.0	adobe-dns.adobe.com
0.0.0.0	ereg.adobe.com
0.0.0.0	ereg.wip3.adobe.com
0.0.0.0	hl2rcv.adobe.com
0.0.0.0	ims-na1-prprod.adobelogin.com
0.0.0.0	lm.licenses.adobe.com
0.0.0.0	na1r.services.adobe.com
0.0.0.0	na2m-pr.licenses.adobe.com
0.0.0.0	na4r.services.adobe.com
0.0.0.0	practivate.adobe.com
0.0.0.0	wip3.adobe.com
0.0.0.0	wwis-dubc1-vip60.adobe.com
#</Adobe>
###############################################################################" >> /etc/hosts
