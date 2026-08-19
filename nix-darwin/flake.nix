{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Prebuilt nix-index database, refreshed weekly upstream. Without it,
    # `nix-index` has to crawl all of nixpkgs locally, which takes hours.
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # nix-homebrew pins the brew release itself and keeps up with the floating
    # homebrew-core/-cask snapshots, so its default is used as-is.
    #
    # If brew ever lags again and `brew bundle` starts reporting formulae or
    # casks as "unreadable: undefined method ...", override the release without
    # duplicating it in the lock:
    #
    #   brew-src = { url = "github:Homebrew/brew/<tag>"; flake = false; };
    #   nix-homebrew.inputs.brew-src.follows = "brew-src";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

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
    # Whisky (fork of the archived upstream, which had no tap of its own)
    homebrew-frankea = {
      url = "github:frankea/homebrew-whisky";
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
      nix-index-database,
      homebrew-core,
      homebrew-cask,
      homebrew-nikitabobko,
      homebrew-docker,
      homebrew-frankea,
      ...
    }:
    let
      specialArgs = {
        inherit self nixpkgs;
        homebrewCore = homebrew-core;
        homebrewCask = homebrew-cask;
        homebrewNikitabobko = homebrew-nikitabobko;
        homebrewDocker = homebrew-docker;
        homebrewFrankea = homebrew-frankea;
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
          nix-index-database.darwinModules.nix-index
        ];
      };

      # The Synology, which runs single-user Nix and neither NixOS nor
      # nix-darwin, so it gets a standalone home configuration rather than a
      # system one. It shares this flake.lock with the MacBook.
      #
      # Applied on the NAS itself:
      #   nix build ~/dotfiles/nix-darwin#homeConfigurations.\"julio@nas\".activationPackage
      #   ./result/activate -b hm-bak
      homeConfigurations."julio@nas" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [ ./modules/home-manager/nas.nix ];
      };
    };
}
