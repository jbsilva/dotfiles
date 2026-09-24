###############################################################################
# Synology RS2423+ (x86_64-linux)
#
# The DSM profile in synology.nix, plus what only this box needs: it runs the
# atuin server, and it is where Rust and FLAC work happens.
###############################################################################
{ lib, pkgs, ... }:
{
  imports = [ ./synology.nix ];

  # The one machine that cannot use the caddy name every other machine syncs
  # to. caddy holds a macvlan address on the LAN, and the kernel refuses
  # traffic between a macvlan address and its parent interface, which is this
  # NAS. So atuin.nas.juliobs.com.br resolves here and then fails to connect,
  # and that is true of every name caddy serves, in both directions.
  #
  # The atuin stack publishes 127.0.0.1:8888 for this. It is the same server
  # the name reaches from elsewhere, one hop earlier, so the history is the
  # same history. Plaintext costs nothing over loopback.
  #
  # mkForce because programs/atuin.nix sets this for everything else.
  programs.atuin.settings.sync_address = lib.mkForce "http://127.0.0.1:8888";

  home.packages = with pkgs; [
    rustup # toolchain manager; the toolchains live in ~/.rustup, outside Nix
    flac # encodes and decodes the FLAC lossless audio format
  ];
}
