{
  config,
  lib,
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
      # mise: node/python/go toolchain versions, replaces nvm and asdf.
      # Homebrew rather than nixpkgs on purpose -- nixpkgs has no cached darwin
      # build at the pinned revision, so it compiles for ~20 min on every
      # flake update. Homebrew ships a bottle and tracks releases faster.
      "mise"
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
      # "adobe-acrobat-reader"
      "adobe-creative-cloud"
      "bambu-studio"
      "betterdisplay"
      "bettertouchtool"
      "bruno"
      "canon-eos-utility"
      "claude-code@latest"
      "codeql"
      # "cursor"
      "daisydisk"
      "db-browser-for-sqlite"
      "discord"
      "docker/tap/sbx"
      "elgato-stream-deck"
      "firefox"
      "fork"
      "ghostty"
      # "gitbutler"
      "gitkraken"
      "insta360-link-controller"
      "keyboard-maestro"
      "lm-studio"
      "lulu"
      "maccy"
      "mactex"
      "meld"
      "microsoft-office"
      "nikitabobko/tap/aerospace"
      "notunes"
      "obs"
      "obsidian"
      "ollama-app"
      # "openmtp"
      "plex"
      "postman"
      "proton-drive"
      "proton-mail"
      "proton-mail-bridge"
      "protonvpn"
      "roon"
      # "spotify"
      "stats"
      "steam"
      "tailscale-app"
      "telegram"
      "thaw"
      "thunderbird"
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
