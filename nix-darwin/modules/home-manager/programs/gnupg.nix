{
  lib,
  ...
}:
{
  # GPG and gpg-agent are installed via Homebrew (brews: gnupg, pinentry-mac)
  # rather than nix, because home-manager's gpg-agent launchd integration is
  # broken on macOS:
  #
  # - --supervised mode (home-manager default): Expects systemd-style socket
  #   activation via LISTEN_FDS. macOS launchd can't pass fds this way, so
  #   gpg-agent crashes: "fd 3 must be valid in --supervised mode".
  #   KeepAlive causes an infinite crash-restart loop.
  #
  # - --daemon --no-detach: gpg-agent --daemon always forks. The parent exits
  #   immediately, launchd loses the child, and treats it as a crash.
  #
  # - Socket path override (SockPathName -> ~/.gnupg/S.gpg-agent): Fixes the
  #   path mismatch but not the --supervised fd-passing failure.
  #
  # - On-demand auto-start (no launchd agent): GnuPG 2.1+ auto-starts
  #   gpg-agent when needed, but darwin-rebuild triggers it during activation
  #   (before GUI session), creating a stale agent where pinentry-mac can't
  #   display. All subsequent signing reuses this broken agent.
  #
  # With Homebrew gpg + pinentry-mac, the agent auto-starts on demand in the
  # user's GUI session and pinentry-mac works reliably. git.nix points
  # gpg.program at /opt/homebrew/bin/gpg.
  #
  # programs.gpg and services.gpg-agent still use the nix gnupg package
  # internally (for config generation), but the actual gpg/gpg-agent binaries
  # used at runtime come from Homebrew.

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = null;
    extraConfig = ''
      pinentry-program /opt/homebrew/bin/pinentry-mac
    '';
  };

  launchd.agents.gpg-agent.enable = lib.mkForce false;
}
