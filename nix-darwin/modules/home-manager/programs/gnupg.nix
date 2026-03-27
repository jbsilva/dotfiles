{
  lib,
  pkgs,
  ...
}:
{
  # GPG and gpg-agent are installed via Homebrew (brews: gnupg, pinentry-mac)
  # rather than nix. git.nix points gpg.program at /opt/homebrew/bin/gpg.
  #
  # Why not nix gnupg?
  #
  # 1. Launchd integration is broken (all approaches fail on macOS):
  #    - --supervised: needs systemd-style LISTEN_FDS; crashes with "fd 3 must
  #      be valid" under launchd. KeepAlive = infinite crash-restart loop.
  #    - --daemon --no-detach: always forks; launchd loses the child.
  #    - Socket path override: fixes mismatch but not --supervised fd failure.
  #
  # 2. Version mismatch kills pinentry. GnuPG 2.1+ auto-starts gpg-agent on
  #    demand. If the nix gpg-agent (2.4.x) auto-starts first (it's on PATH
  #    via home-manager profile), homebrew gpg (2.5.x) can't talk to it:
  #    the Assuan protocol changed between major versions, so pinentry
  #    requests fail with "No pinentry" even though pinentry-mac is fine.
  #
  # 3. Stale agent context. If gpg-agent auto-starts during darwin-rebuild
  #    (which runs via sudo + launchctl asuser), it inherits a process
  #    context without proper Aqua session access. pinentry-mac then can't
  #    reach macOS Keychain/WindowServer, failing with "No pinentry".
  #    Killing the agent and letting the next gpg operation auto-start a
  #    fresh one in the user's GUI session fixes it.
  #
  # Solution: keep programs.gpg/services.gpg-agent enabled purely for config
  # file management (gpg.conf, gpg-agent.conf), but replace the package with
  # a dummy so no nix gpg/gpg-agent binaries land on PATH. Kill any stale
  # agent after activation so the next use auto-starts cleanly.

  programs.gpg = {
    enable = true;
    # Dummy package: home-manager generates ~/.gnupg/{gpg,gpg-agent}.conf
    # but no nix gpg binaries end up on PATH (avoids version mismatch with
    # homebrew gpg). The empty bin/ satisfies HM's package expectations.
    package = pkgs.runCommandLocal "gnupg-dummy" {
      meta.mainProgram = "gpg";
    } "mkdir -p $out/bin";
  };

  services.gpg-agent = {
    enable = true;
    grabKeyboardAndMouse = false;
    pinentry.package = null;
    extraConfig = ''
      pinentry-program /opt/homebrew/bin/pinentry-mac
    '';
  };

  launchd.agents.gpg-agent.enable = lib.mkForce false;

  # Kill any gpg-agent started during activation (stale context).
  # The next gpg operation auto-starts a fresh agent in the user's
  # GUI session where pinentry-mac can access Keychain.
  home.activation.restartGpgAgent = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if command -v /opt/homebrew/bin/gpgconf >/dev/null 2>&1; then
      /opt/homebrew/bin/gpgconf --kill gpg-agent 2>/dev/null || true
    fi
  '';
}
