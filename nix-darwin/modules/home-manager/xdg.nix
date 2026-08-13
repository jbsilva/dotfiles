{ config, ... }:
let
  # The repo, as a path string. Not a Nix path literal: that would copy the
  # whole repo into the store and defeat the point of linking out of it.
  dotfiles = "${config.home.homeDirectory}/dotfiles";

  # Link ~/.config/<target> -> ~/dotfiles/.config/<target>.
  #
  # mkOutOfStoreSymlink, not the usual `source = ./path`, because every one of
  # these has to stay WRITABLE and live:
  #   * VS Code rewrites settings.json whenever a setting changes
  #   * gh rewrites hosts.yml on `gh auth`
  #   * lazy.nvim writes lazy-lock.json into the nvim config dir
  #   * `brew trust` writes trust.json
  # A normal home.file would point at a read-only /nix/store path, so those
  # writes would fail, and editing a config would need a rebuild to take effect.
  link = target: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/${target}";
in
{
  ###########################################################################
  # XDG config
  #
  # ~/.config used to be a single symlink to ~/dotfiles/.config, which meant
  # every application on the machine wrote its runtime state inside the git
  # repo -- Colima's ~18 GB VM image included -- and Linux-only files leaked
  # onto macOS.
  #
  # ~/.config is now a real directory. Only the files actually tracked in git
  # are linked back into it, one by one. Everything else an application creates
  # stays outside the repo where it belongs.
  #
  # Granularity rule: link a whole directory only when the directory is
  # entirely ours (nvim). Where an application keeps its own state alongside
  # our config (VS Code's globalStorage, gh's state.yml), link the individual
  # files so that state is not dragged into the repo.
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

    # tmux.conf is itself a symlink into the .tmux submodule; tmux follows it.
    "tmux/tmux.conf".source = link "tmux/tmux.conf";
    "tmux/tmux.conf.local".source = link "tmux/tmux.conf.local";
  };
}
