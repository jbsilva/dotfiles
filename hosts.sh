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
0.0.0.0 lmlicenses.wip4.adobe.com
0.0.0.0 lm.licenses.adobe.com
0.0.0.0 hlrcv.stage.adobe.com
#</Adobe>
###############################################################################
#<Spotify>
0.0.0.0 pubads.g.doubleclick.net
0.0.0.0 securepubads.g.doubleclick.net
0.0.0.0 www.googletagservices.com
0.0.0.0 gads.pubmatic.com
0.0.0.0 ads.pubmatic.com
0.0.0.0 spclient.wg.spotify.com
#</Spotify>
###############################################################################
#<VueScan>
0.0.0.0 www.hamrick.com
0.0.0.0 static.hamrick.com
0.0.0.0 stats.hamrick.com
0.0.0.0 104.131.17.148 
#</VueScan>
###############################################################################" >> /etc/hosts
