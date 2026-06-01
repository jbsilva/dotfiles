{
  description = "nix-darwin system flake";

  inputs = {
    # Pinned before Homebrew/brew#22476 (tap-trust-eval-all) which breaks
    # nix-homebrew's nix-store symlinks.  Remove pin once nix-homebrew
    # handles the new realpath validation.
    brew-src = {
      url = "github:Homebrew/brew/7470da65dd677d3d4b6cc6e5e4bfeeaa39c06b80";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.brew-src.follows = "brew-src";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    # AeroSpace
    homebrew-nikitabobko = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    # Docker (sbx)
    homebrew-docker = {
      url = "github:docker/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      nix-homebrew,
      home-manager,
      homebrew-core,
      homebrew-cask,
      homebrew-nikitabobko,
      homebrew-docker,
      ...
    }:
    let
      specialArgs = {
        inherit self nixpkgs;
        homebrewCore = homebrew-core;
        homebrewCask = homebrew-cask;
        homebrewNikitabobko = homebrew-nikitabobko;
        homebrewDocker = homebrew-docker;
      };
    in
    {
      # Update:  nix flake update
      # Rebuild: sudo darwin-rebuild --show-trace switch --flake .#M4
      # GC and store optimisation are handled automatically by nix.gc and nix.optimise.
      darwinConfigurations.M4 = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [
          ./modules
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
        ];
      };
    };
}
