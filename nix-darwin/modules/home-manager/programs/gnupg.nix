{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = null; # pkgs.pinentry_mac was causing issues
    extraConfig = ''
      pinentry-program /opt/homebrew/bin/pinentry-mac
    '';
  };

}
