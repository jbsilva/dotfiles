{ ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.julio =
      { ... }:
      {
        imports = [
          ./programs/gnupg.nix
          ./programs/git.nix
          ./programs/zsh.nix
          ./programs/direnv.nix
          ./programs/atuin.nix
          ./activation/docker-plugins.nix
          ./activation/default-apps.nix
          ./activation/remove-lm-studio-login-item.nix
          ./activation/disable-ollama.nix
          ./activation/disable-onedrive.nix
          ./activation/disable-adobe-creative-cloud.nix
          ./activation/tflint-plugins.nix
          ./activation/homebrew-trust.nix
        ];

        home.username = "julio";
        home.stateVersion = "26.05";

        home.packages = [ ];
      };
  };
}
