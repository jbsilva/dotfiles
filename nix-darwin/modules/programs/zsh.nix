{ ... }:
let
  # Homebrew's shellenv plus Nix profile precedence. Identical for login and
  # interactive shells, so it is defined once and reused by both hooks below.
  # Both blocks are idempotent, which matters because a login+interactive shell
  # (a normal terminal) runs them back to back.
  brewAndNixPath = ''
    # Ensure Homebrew environment (PATH, MANPATH, INFOPATH) is set up
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(! /opt/homebrew/bin/brew shellenv 2>/dev/null || /opt/homebrew/bin/brew shellenv)"
    fi

    # Ensure Nix paths take precedence over macOS and Homebrew.
    # Use zsh's $path array for reliable de-duplication and ordering.
    if [ -n "$ZSH_VERSION" ]; then
      typeset -U path
      path=(
        /run/current-system/sw/bin
        /etc/profiles/per-user/$USER/bin
        $path
      )
    else
      # Fallback for non-zsh shells
      export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$PATH"
    fi

    # Keep OpenJDK bin visible even if path_helper overwrote PATH earlier
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
  '';
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    loginShellInit = ''
      # Honor macOS /etc/paths and /etc/paths.d (e.g., MacTeX installs /Library/TeX/texbin)
      if [ -x /usr/libexec/path_helper ]; then
        eval "$(/usr/libexec/path_helper -s)"
      fi

      ${brewAndNixPath}
    '';

    interactiveShellInit = ''
      # If a terminal starts a non-login interactive shell, ensure system paths are
      # still loaded. Skipped when texbin is already present, so the common
      # login+interactive case does not pay for path_helper twice.
      if [ -x /usr/libexec/path_helper ]; then
        case ":$PATH:" in
          *:/Library/TeX/texbin:*) : ;; # already present
          *) eval "$(/usr/libexec/path_helper -s)" ;;
        esac
      fi

      ${brewAndNixPath}
    '';
  };
}
