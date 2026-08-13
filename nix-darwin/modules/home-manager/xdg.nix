{ config, ... }:
let
  # The repo, as a path string. Not a Nix path literal: that would copy the
  # whole repo into the store and defeat the point of linking out of it.
  dotfiles = "${config.home.homeDirectory}/dotfiles";

  # Link ~/.config/<target> -> ~/dotfiles/.config/<target>.
  #
  # mkOutOfStoreSymlink rather than `source = ./path`, which would point at a
  # read-only /nix/store path. These files are written by the applications
  # themselves -- VS Code rewrites settings.json, gh rewrites hosts.yml on
  # `gh auth`, lazy.nvim writes lazy-lock.json -- and editing one should take
  # effect without a rebuild.
  link = target: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/${target}";
in
{
  ###########################################################################
  # XDG config
  #
  # ~/.config is a real directory, with only the files tracked in git linked
  # back into it. Everything else an application writes there stays out of the
  # repo.
  #
  # Granularity rule: link a whole directory only when it is entirely ours
  # (nvim). Where an application keeps its own state alongside our config
  # (VS Code's globalStorage, gh's state.yml), link the individual files.
  ###########################################################################
  xdg.configFile = {
    # Entirely ours, so link the directory. lazy-lock.json and the lazy/mason
    # state land in the repo, where .gitignore already covers them.
    "nvim".source = link "nvim";

    # VS Code keeps globalStorage/, workspaceStorage/, History/ and CachedData/
    # in Code/, so link only the two files that are ours.
    "Code/User/settings.json".source = link "Code/User/settings.json";
    "Code/User/keybindings.json".source = link "Code/User/keybindings.json";

    # gh also writes state.yml here.
    "gh/config.yml".source = link "gh/config.yml";
    "gh/hosts.yml".source = link "gh/hosts.yml";

    "pypoetry/config.toml".source = link "pypoetry/config.toml";

  };
}
