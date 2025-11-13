{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    loginShellInit = ''
      # Honor macOS /etc/paths and /etc/paths.d (e.g., MacTeX installs /Library/TeX/texbin)
      if [ -x /usr/libexec/path_helper ]; then
        eval "$(/usr/libexec/path_helper -s)"
      fi

      # Ensure Homebrew environment (PATH, MANPATH, INFOPATH) is set up
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(! /opt/homebrew/bin/brew shellenv 2>/dev/null || /opt/homebrew/bin/brew shellenv)"
      fi

      # Ensure Nix paths take precedence over macOS and Homebrew
      # Use zsh's $path array for reliable de-duplication and ordering
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

    interactiveShellInit = ''
      # If a terminal starts a non-login interactive shell, ensure system paths are still loaded
      if [ -x /usr/libexec/path_helper ]; then
        case ":$PATH:" in
          *:/Library/TeX/texbin:*) : ;; # already present
          *) eval "$(/usr/libexec/path_helper -s)" ;;
        esac
      fi

      # Homebrew shell environment (idempotent; safe to eval multiple times)
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(! /opt/homebrew/bin/brew shellenv 2>/dev/null || /opt/homebrew/bin/brew shellenv)"
      fi

      # Ensure Nix paths take precedence over macOS and Homebrew for interactive shells, too
      if [ -n "$ZSH_VERSION" ]; then
        typeset -U path
        path=(
          /run/current-system/sw/bin
          /etc/profiles/per-user/$USER/bin
          $path
        )
      else
        export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$PATH"
      fi

      # Keep OpenJDK bin visible
      export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    '';
  };
}
