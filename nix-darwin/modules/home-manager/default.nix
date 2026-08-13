{ ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Move an unmanaged file aside rather than aborting activation when one is
    # sitting where home-manager wants to write. Applications that generate a
    # default config on first run would otherwise fail the whole switch.
    backupFileExtension = "hm-bak";
    users.julio =
      { ... }:
      {
        imports = [
          ./xdg.nix
          ./programs/gnupg.nix
          ./programs/git.nix
          ./programs/zsh.nix
          ./programs/bash.nix
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
