{ ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
    };

    hostPlatform = "aarch64-darwin";

    overlays = [
      (_final: prev: {
        # direnv 2.37.1 uses -linkmode=external but CGO is disabled on darwin.
        direnv = prev.direnv.overrideAttrs (old: {
          env = (old.env or { }) // {
            CGO_ENABLED = "1";
          };
          # Work around hanging test runs on Darwin during checkPhase.
          doCheck = false;
        });
        # atuin 18.23.0: the e2e_capture and e2e_pty tests drive a shell through a
        # pty and fail inside the darwin build sandbox.
        atuin = prev.atuin.overrideAttrs { doCheck = false; };
      })
    ];
  };
}
