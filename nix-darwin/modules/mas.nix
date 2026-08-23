{ ... }:
{
  # Apps with no cask and nothing in nixpkgs, so the App Store is the only way
  # to install them.
  #
  # `mas` does the installing and comes from packages.nix. It only handles apps
  # this Apple ID already owns, so the very first install of each one has to go
  # through the App Store app.
  #
  # nix-darwin has no top-level option for this, so it sits under `homebrew`,
  # which writes the `mas` lines into the generated Brewfile.
  homebrew.masApps = {
    Amphetamine = 937984704; # keep the Mac awake, on rules and triggers
    "ShutterCount Pro" = 1441290690; # read the shutter count off a Canon body
    WireGuard = 1451685025; # the official client; wireguard-tools is the CLI
  };
}
