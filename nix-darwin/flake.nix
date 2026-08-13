{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # nix-homebrew's built-in brew lags the floating homebrew-core/-cask
    # snapshots, which keep adopting new DSL as soon as it ships. Track the
    # latest stable brew here instead and wire it in via nix-homebrew.package
    # below. Bump this tag whenever `brew bundle` starts reporting formulae or
    # casks as "unreadable: undefined method ...".
    #   6.0.9  added Resource::Patch `type`/`resolves` (Homebrew/brew#22466)
    #   6.0.12 added InstallSteps::DSL `on_macos`/`on_linux`
    #   6.0.13 added InstallSteps::DSL `run`/`terminate_process` and the
    #          `command_wrapper` cask artifact
    #   6.0.15 added formula install-step `:overwrite` keyword
    brew-src = {
      url = "github:Homebrew/brew/6.0.15";
      flake = false;
    };
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
      brew-src,
      homebrew-core,
      homebrew-cask,
      homebrew-nikitabobko,
      homebrew-docker,
      ...
    }:
    let
      specialArgs = {
        inherit self nixpkgs;
        brewSrc = brew-src;
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
