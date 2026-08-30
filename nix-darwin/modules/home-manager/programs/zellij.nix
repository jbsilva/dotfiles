{ config, ... }:
{
  ###########################################################################
  # Zellij
  #
  # Shared by the MacBook and the NAS, because nested sessions only work when
  # both ends agree: `.zshrc` starts a session on SSH login, and the host has
  # to be configured to zoom into it. See the Zellij section of the README.
  #
  # Linked out of the repo rather than copied into the store. Zellij rewrites
  # config.kdl in place when it upgrades to a version with new options, and the
  # configuration plugin writes to it as well; a store path is read-only and
  # would turn both into an error. Same reasoning as xdg.nix.
  #
  # config.kdl alone, not the whole directory: Zellij keeps layouts/ and
  # themes/ beside it, which are not tracked here.
  ###########################################################################
  xdg.configFile."zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/zellij/config.kdl";
}
