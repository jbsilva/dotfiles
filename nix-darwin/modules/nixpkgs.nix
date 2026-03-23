{ ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
    };

    hostPlatform = "aarch64-darwin";

    overlays = [
      (final: prev: {
        # direnv 2.37.1 uses -linkmode=external but CGO is disabled on darwin.
        direnv = prev.direnv.overrideAttrs (old: {
          env = (old.env or { }) // {
            CGO_ENABLED = "1";
          };
        });
      })
    ];
  };
}
