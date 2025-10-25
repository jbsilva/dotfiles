{
  homebrewCore,
  homebrewCask,
  homebrewNikitabobko,
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
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
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
      "harfbuzz"
      "imagemagick"
      "libpq"
      "libraqm"
      "lima-additional-guestagents"
      "nginx"
      "openjdk"
      "openssl"
      "telnet"
    ];
    casks = [
      "adobe-acrobat-reader"
      "adobe-creative-cloud"
      "bambu-studio"
      "betterdisplay"
      "bettertouchtool"
      "cursor"
      "elgato-stream-deck"
      "fork"
      "ghostty"
      "gitbutler"
      "keyboard-maestro"
      "lm-studio"
      "maccy"
      "mactex"
      "microsoft-office"
      "nikitabobko/tap/aerospace"
      "notunes"
      "obs"
      "obsidian"
      "ollama-app"
      "plex"
      "postman"
      "telegram"
      "spotify"
      "stats"
      "tailscale-app"
      "transmission-remote-gui"
      "ubiquiti-unifi-controller"
      "vivaldi"
      "warp"
    ];
  };
}
