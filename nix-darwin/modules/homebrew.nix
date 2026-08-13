{
  config,
  lib,
  brewSrc,
  homebrewCore,
  homebrewCask,
  homebrewNikitabobko,
  homebrewDocker,
  ...
}:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "julio";
    # Override nix-homebrew's built-in brew with the tag pinned in flake.nix so
    # formulae/casks using newer DSL are readable. Keep in sync with brew-src.
    package = brewSrc // {
      name = "brew-6.0.15";
      version = "6.0.15";
    };
    taps = {
      "homebrew/homebrew-core" = homebrewCore;
      "homebrew/homebrew-cask" = homebrewCask;
      "nikitabobko/homebrew-tap" = homebrewNikitabobko;
      "docker/homebrew-tap" = homebrewDocker;
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
      # Homebrew 4.x requires --force/--force-cleanup/$HOMEBREW_ASK to run
      # `brew bundle --cleanup` non-interactively. nix-darwin emits --cleanup
      # without it, so authorize the uninstall explicitly here.
      extraFlags = [ "--force-cleanup" ];
    };
    # `brew bundle cleanup` untaps every installed tap the Brewfile doesn't
    # mention (only homebrew/core is exempt), and untapping homebrew/cask
    # force-uninstalls all 47 casks that came from it. So mirror nix-homebrew's
    # taps into the Brewfile. Homebrew normalises `owner/homebrew-repo` to
    # `owner/repo` and cleanup compares those names literally, so strip the
    # `homebrew-` prefix or the entries won't match and cleanup still untaps.
    taps = lib.mapAttrsToList (
      name: _:
      let
        parts = lib.splitString "/" name;
      in
      "${lib.head parts}/${lib.removePrefix "homebrew-" (lib.last parts)}"
    ) config.nix-homebrew.taps;
    brews = [
      "colima"
      "docker"
      "docker-buildx"
      "docker-compose"
      "duckdb"
      "freetype"
      "fribidi"
      "gh"
      "gnupg"
      "gphoto2"
      "harfbuzz"
      "hugo"
      "imagemagick"
      "libpq"
      "libraqm"
      "lima-additional-guestagents"
      # "llmfit"
      "nginx"
      "openjdk"
      "openssl"
      "pinentry-mac"
      "redocly-cli"
      "shellcheck"
      "skopeo"
      "socat"
      "sonar-scanner"
      "starship"
      "telnet"
      "terminal-notifier"
      "yt-dlp"
    ];
    casks = [
      "adobe-acrobat-reader"
      "adobe-creative-cloud"
      "bambu-studio"
      "betterdisplay"
      "bettertouchtool"
      "bruno"
      "canon-eos-utility"
      "claude-code@latest"
      "cursor"
      "daisydisk"
      "db-browser-for-sqlite"
      "discord"
      "docker/tap/sbx"
      "elgato-stream-deck"
      "firefox"
      "fork"
      "ghostty"
      "gitbutler"
      "gitkraken"
      "insta360-link-controller"
      "keyboard-maestro"
      "lm-studio"
      "lulu"
      "maccy"
      "mactex"
      "microsoft-office"
      "nikitabobko/tap/aerospace"
      "notunes"
      "obs"
      "obsidian"
      "ollama-app"
      "openmtp"
      "plex"
      "postman"
      "proton-mail"
      "proton-mail-bridge"
      "roon"
      "spotify"
      "stats"
      "steam"
      "tailscale-app"
      "telegram"
      "thaw"
      "thunderbird"
      "transmission-remote-gui"
      "ubiquiti-unifi-controller"
      "visual-studio-code"
      "vivaldi"
      # "voiceink"
      "wacom-tablet"
      "warp"
      "yubico-authenticator"
      "zulip"
    ];
  };
}
