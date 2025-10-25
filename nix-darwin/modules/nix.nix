{ nixpkgs, ... }:
{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      extra-nix-path = "nixpkgs=flake:nixpkgs";
    };

    nixPath = [
      "nixpkgs=${nixpkgs}"
      "darwin-config=${toString ../flake.nix}"
    ];

    registry = {
      nixpkgs = {
        flake = nixpkgs;
      };
    };

    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';

    gc = {
      automatic = true;
      interval = {
        Hour = 3;
        Minute = 15;
      };
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
      interval = {
        Hour = 4;
        Minute = 15;
      };
    };

    linux-builder.enable = true;
  };
}
