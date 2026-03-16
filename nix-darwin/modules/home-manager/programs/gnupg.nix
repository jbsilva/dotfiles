{
  pkgs,
  config,
  lib,
  ...
}:
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

  # The home-manager gpg-agent module creates a launchd agent with socket
  # activation at /private/var/run/..., but gpg connects to
  # ~/.gnupg/S.gpg-agent. This mismatch means socket activation never fires.
  # Override to use --daemon mode so the agent manages its own socket, and
  # start at login so it runs in the GUI session where pinentry-mac works.
  launchd.agents.gpg-agent.config = lib.mkForce {
    Label = "org.nix-community.home.gpg-agent";
    ProgramArguments = [
      "${pkgs.gnupg}/bin/gpg-agent"
      "--daemon"
      "--no-detach"
    ];
    EnvironmentVariables = {
      GNUPGHOME = "${config.home.homeDirectory}/.gnupg";
    };
    RunAtLoad = true;
    KeepAlive = {
      Crashed = true;
      SuccessfulExit = false;
    };
    ProcessType = "Background";
  };
}
