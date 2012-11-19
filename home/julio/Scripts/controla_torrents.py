#!/usr/bin/env python2
# -*-*- encoding: utf-8 -*-*-
# Created: Wed, 16 May 2012 18:10:35 -0300

"""
Altera velocidade limite de download e upload do rTorrent

Para executar regularmente, adicione ao contrab:
    De hora em hora: @hourly /home/julio/Scripts/controla_torrents.py -u 0
    A cada 2 horas: * */2 * * * /home/julio/Scripts/controla_torrents.py -u 0
"""
__author__ = "Julio Batista Silva"
__copyright__ = ""
__license__ = "GPL"
__version__ = "1.0"

import argparse
import xmlrpclib
import xmlrpc2scgi as xmlrpc


class Rtorrent:
    def __init__(self, host, porta="80", tipo="http"):
        if tipo == "http":
            self.s = xmlrpclib.ServerProxy('http://{}:{}'.format(host, porta))
        if tipo == "scgi":
            self.s = xmlrpc.RTorrentXMLRPCClient("scgi://{}:{}".
                    format(host, porta))

    def get_up_rate(self):
        return self.s.get_upload_rate()

    def set_up_rate(self, rate):
        return self.s.set_upload_rate(rate)

    def get_down_rate(self):
        return self.s.get_download_rate()

    def set_down_rate(self, rate):
        return self.s.set_download_rate(rate)


def main(upload=-1, download=-1):
    #r = Rtorrent("casa.juliobs.com", "80", "http")
    r = Rtorrent("127.0.0.1", "5000", "scgi")

    if upload >= 0:
        new_up = upload * 1024
        r.set_up_rate(new_up)

    if download >= 0:
        new_down = download * 1024
        r.set_down_rate(new_down)

    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
            description='Altera limites de velocidade do rTorrent')
    parser.add_argument('-u', '--upload', type=int,
            help='Velocidade de upload')
    parser.add_argument('-d', '--download', type=int,
            help='Velocidade de download')
    args = parser.parse_args()

    main(args.upload, args.download)
