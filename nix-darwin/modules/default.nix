{ ... }:
{
  imports = [
    ./nixpkgs.nix
    ./users.nix
    ./environment.nix
    ./programs/zsh.nix
    ./packages.nix
    ./fonts.nix
    ./homebrew.nix
    ./nix.nix
    ./security.nix
    ./system/meta.nix
    ./system/activation.nix
    ./system/defaults.nix
    ./home-manager
  ];
}
