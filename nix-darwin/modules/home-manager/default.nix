{ ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.julio =
      { ... }:
      {
        imports = [
          ./programs/git.nix
          ./programs/zsh.nix
          ./programs/direnv.nix
          ./activation/docker-plugins.nix
          ./activation/default-apps.nix
          ./activation/remove-lm-studio-login-item.nix
          ./activation/disable-onedrive.nix
          ./activation/disable-adobe-creative-cloud.nix
        ];

        home.username = "julio";
        home.stateVersion = "24.05";

        home.packages = [ ];
      };
  };
}
