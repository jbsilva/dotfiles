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
    # ntfs-3g-mac. homebrew-core dropped the FUSE formulae, and this tap keeps
    # them, with bottles. The formula itself is commented out in
    # modules/homebrew.nix; the tap stays so turning it back on is a one-file
    # change there.
    homebrew-gromgit = {
      url = "github:gromgit/homebrew-fuse";
      flake = false;
    };

    # A collection of `git-*` scripts, packaged in modules/git-extra-commands.nix.
    #
    # An input rather than a `fetchFromGitHub` with a rev and a hash in the
    # module: Renovate cannot compute a fixed-output hash, so that form can only
    # be bumped by hand. flake.lock carries both, so `just update` moves it.
    git-extra-commands = {
      url = "github:unixorn/git-extra-commands";
      flake = false;
    };

    # Decrypts the sops files in ../secrets/ at activation. See secrets/README.md.
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
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
      homebrew-gromgit,
      git-extra-commands,
      sops-nix,
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
        homebrewGromgit = homebrew-gromgit;
        gitExtraCommandsSrc = git-extra-commands;
      };

      # A standalone home-manager configuration, for the machines that run
      # neither NixOS nor nix-darwin. They share this flake, and so flake.lock,
      # with the MacBook.
      #
      # Applied on the machine itself, or through the `just nas-switch` family:
      #   nix build ~/dotfiles/nix-darwin#homeConfigurations.\"julio@HOST\".activationPackage
      #   ./result/activate -b hm-bak
      mkHome =
        module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ module ];
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
          sops-nix.darwinModules.sops
        ];
      };

      homeConfigurations = {
        # The Synology. Single-user Nix, DSM rather than a distribution, and a
        # store on a bind-mounted volume. Its module carries the shims DSM
        # needs; see modules/home-manager/nas.nix.
        "julio@nas" = mkHome ./modules/home-manager/nas.nix;

        # Arch on the desktop and Ubuntu under WSL on the work machine. Both
        # take the same module: they are ordinary x86_64 Linux with Nix
        # installed, and .zshrc already tells them apart at runtime through
        # $DOTFILES_PLATFORM. Split them when they need to differ.
        "julio@arch" = mkHome ./modules/home-manager/linux.nix;
        "julio@wsl" = mkHome ./modules/home-manager/linux.nix;
      };
    };
}
