{ ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # When an unmanaged file is already sitting where home-manager wants to put
    # one, move it aside instead of aborting the whole activation. Without this,
    # a single stray file fails the switch -- which is exactly what happened when
    # Atuin had written its default config.toml before home-manager first ran.
    backupFileExtension = "hm-bak";
    users.julio =
      { ... }:
      {
        imports = [
          ./xdg.nix
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
        ];

        home.username = "julio";
        home.stateVersion = "26.05";

        home.packages = [ ];
      };
  };
}
