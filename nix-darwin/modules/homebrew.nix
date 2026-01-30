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
      "gphoto2"
      "harfbuzz"
      "hugo"
      "imagemagick"
      "libpq"
      "libraqm"
      "lima-additional-guestagents"
      "nginx"
      "opencode"
      "openjdk"
      "openssl"
      "pinentry-mac"
      "starship"
      "telnet"
    ];
    casks = [
      "adobe-acrobat-reader"
      "adobe-creative-cloud"
      "bambu-studio"
      "betterdisplay"
      "bettertouchtool"
      "canon-eos-utility"
      "cursor"
      "elgato-stream-deck"
      "fork"
      "ghostty"
      "gitbutler"
      "gitkraken"
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
      "openmtp"
      "plex"
      "postman"
      "spotify"
      "stats"
      "steam"
      "tailscale-app"
      "telegram"
      "transmission-remote-gui"
      "ubiquiti-unifi-controller"
      "vivaldi"
      "warp"
      "yubico-authenticator"
    ];
  };
}
