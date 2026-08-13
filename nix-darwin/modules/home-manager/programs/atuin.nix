{ ... }:
{
  ###########################################################################
  # Atuin -- SQLite-backed shell history
  #
  # Replaces the flat ~/.zsh_history append-only file with a database that
  # records exit code, duration, cwd and session for every command, and gives
  # Ctrl-R a real fuzzy search over it.
  #
  # enableZshIntegration is off on purpose. home-manager would inject
  # `atuin init zsh` ahead of initContent, and .zshrc binds Ctrl-R further
  # down, so .zshrc would silently win and Atuin's search would never appear.
  # The init lives in .zshrc instead, after the keybindings, which also means
  # the Arch and WSL machines get Atuin as soon as the binary is on PATH.
  #
  # Sync is not configured: it needs an account and a key. To enable it later:
  #   atuin register -u <user> -e <email>   (or `atuin login`)
  #   atuin import auto && atuin sync
  # The key lives in ~/.local/share/atuin/key -- back it up, it is the only way
  # to decrypt synced history.
  ###########################################################################
  programs.atuin = {
    enable = true;
    enableZshIntegration = false;

    settings = {
      # Do not run the selected command straight away; put it on the command
      # line so it can be edited first. Atuin's default is to execute it, which
      # is a sharp edge when the search lands on something destructive.
      enter_accept = false;

      # Fuzzy matching rather than prefix matching.
      search_mode = "fuzzy";

      # Default to this host's history; Ctrl-R cycles the filter mode.
      filter_mode = "host";

      # Up-arrow (when bound) searches only the current session.
      filter_mode_shell_up_key_binding = "session";

      # Compact inline UI instead of taking over the whole terminal.
      style = "compact";
      inline_height = 20;
      show_preview = true;
      show_help = false;

      # Nix owns the version; do not phone home on startup.
      update_check = false;

      # Keep secrets out of the database in the first place.
      secrets_filter = true;

      # Never record these, regardless of secrets_filter.
      history_filter = [
        "^\\s" # a leading space still means "do not record"
        "^kubectl.*--token"
        "^aws .*secret"
        "^export .*(TOKEN|SECRET|PASSWORD|KEY)="
        "password"
      ];
    };
  };
}
