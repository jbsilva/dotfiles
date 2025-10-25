{ ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
    };

    hostPlatform = "aarch64-darwin";
  };
}
