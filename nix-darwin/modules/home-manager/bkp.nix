###############################################################################
# Synology DS1522+ (x86_64-linux)
#
# The backup box. It runs the DSM profile in synology.nix and adds nothing.
# atuin syncs to the same server as the MacBook, by the same name.
###############################################################################
{
  imports = [ ./synology.nix ];
}
