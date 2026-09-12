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
  # Sync points at the server in the atuin stack of the nas-containers
  # repository, not at the hosted atuin.sh. History is a record of every command
  # run on every machine, which is a better map of this network than the SSH
  # config, and it stays on hardware here.
  #
  # Registration is one command per machine, and is not declarative because it
  # writes a session token:
  #
  #   atuin register -u julio -e <email>   # first machine only
  #   atuin login -u julio                 # every machine after that
  #   atuin import auto && atuin sync
  #
  # The encryption key lives in ~/.local/share/atuin/key. Back it up. The server
  # only ever sees ciphertext, so a lost key loses the synced history whatever
  # the NAS still holds. `atuin key` prints it.
  #
  # The name resolves to an address on the home LAN, so sync works there and
  # over the gateway's VPN, and nothing is exposed to the internet. Away from
  # both, sync simply does not happen: the client keeps recording locally and
  # uploads the backlog next time it can reach the server. There is nothing to
  # configure for that and no error to expect.
  ###########################################################################
  programs.atuin = {
    enable = true;
    enableZshIntegration = false;

    settings = {
      # Self-hosted, in the atuin stack of the nas-containers repository. The
      # name is caddy's: one `handle` under its BASE_DOMAIN, covered by a
      # wildcard certificate that is already there, on 443 with no port.
      #
      # This string has to match that handle exactly. It is the only way in,
      # because that stack publishes no port of its own, and a mismatch fails
      # the way everything else here fails: quietly, with Ctrl-R still working
      # and nothing being uploaded. `atuin status` is what says so.
      sync_address = "https://atuin.nas.juliobs.com.br";

      # Sync on its own rather than only when `atuin sync` is typed. The point
      # of this is that a command run on the NAS is in Ctrl-R on the MacBook,
      # and that only holds if it happens unasked.
      auto_sync = true;
      sync_frequency = "10m";

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
