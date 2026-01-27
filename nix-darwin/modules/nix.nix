{ nixpkgs, ... }:
{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      extra-nix-path = "nixpkgs=flake:nixpkgs";
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-terraform.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
      ];
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
