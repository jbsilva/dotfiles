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

      # Keep OpenJDK bin visible
      export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    '';
  };
}
