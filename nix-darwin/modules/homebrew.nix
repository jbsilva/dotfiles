{
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
    taps = [ ];
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
      "llmfit"
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
      "warp"
      "yubico-authenticator"
    ];
  };
}
