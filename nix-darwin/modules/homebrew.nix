{
  config,
  lib,
  homebrewCore,
  homebrewCask,
  homebrewNikitabobko,
  homebrewDocker,
  homebrewFrankea,
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
      "frankea/homebrew-whisky" = homebrewFrankea;
    };
    mutableTaps = false;
  };

  # Homebrew 6's HOMEBREW_REQUIRE_TAP_TRUST refuses entries from untrusted
  # third-party taps. nix-darwin emits `trusted: true` on every brew and cask it
  # generates, which covers the fully-qualified ones below, so nothing needs to
  # write ~/.homebrew/trust.json.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    # `brew bundle cleanup` untaps every tap the Brewfile omits, and untapping
    # homebrew/cask force-uninstalls every cask from it -- so mirror the taps
    # above. Cleanup compares names literally against Homebrew's normalised
    # `owner/repo`, hence stripping the `homebrew-` prefix.
    taps = lib.mapAttrsToList (
      name: _:
      let
        parts = lib.splitString "/" name;
      in
      "${lib.head parts}/${lib.removePrefix "homebrew-" (lib.last parts)}"
    ) config.nix-homebrew.taps;

    brews = [
      # -----------------------------------------------------------------------
      # Containers
      # -----------------------------------------------------------------------
      "colima" # container runtime on a Lima VM, no Docker Desktop
      "docker" # CLI only; colima provides the daemon
      "docker-buildx" # BuildKit builder, as a docker plugin
      "docker-compose" # multi-container stacks
      "lima-additional-guestagents" # extra guest agents for the Lima VM
      "skopeo" # copy and inspect images without a daemon

      # -----------------------------------------------------------------------
      # Development
      # -----------------------------------------------------------------------
      "gh" # GitHub CLI
      "mise" # node/python/go versions, replacing nvm and asdf
      "openjdk" # Java development kit
      "redocly-cli" # lint and bundle OpenAPI specs
      "shellcheck" # run by the pre-commit hook
      "sonar-scanner" # SonarQube analysis client
      "hugo" # static site generator

      # -----------------------------------------------------------------------
      # Data
      # -----------------------------------------------------------------------
      "duckdb" # embedded analytical SQL
      "libpq" # psql and the client library, without a local server

      # -----------------------------------------------------------------------
      # Media & image processing
      # -----------------------------------------------------------------------
      "freetype" # font renderer
      "fribidi" # Unicode bidi algorithm
      "harfbuzz" # OpenType text shaping
      "libraqm" # complex text layout; pulls in the three above
      "imagemagick" # image conversion and manipulation
      "gphoto2" # tethered capture and camera control
      "yt-dlp" # YouTube downloader. Homebrew updates more often than nixpkgs

      # -----------------------------------------------------------------------
      # Networking
      # -----------------------------------------------------------------------
      "nginx" # HTTP server and reverse proxy
      "openssl" # TLS and crypto toolkit
      "socat" # netcat with more socket types
      "telnet" # TELNET client

      # -----------------------------------------------------------------------
      # Secrets & signing
      # -----------------------------------------------------------------------
      "gnupg" # OpenPGP signing and encryption
      "pinentry-mac" # native macOS passphrase prompt for GnuPG

      # -----------------------------------------------------------------------
      # Shell integration
      # -----------------------------------------------------------------------
      "starship" # prompt
      "terminal-notifier" # macOS notifications from the command line

      # -----------------------------------------------------------------------
      # Local LLM runtimes -- off; the lm-studio and ollama-app casks cover this
      # -----------------------------------------------------------------------
      # "llama.cpp"
      # "llmfit"
    ];

    casks = [
      # -----------------------------------------------------------------------
      # Development
      # -----------------------------------------------------------------------
      "claude-code@latest" # terminal coding agent
      "codeql" # semantic code analysis
      "db-browser-for-sqlite" # SQLite GUI
      "docker/tap/sbx" # Docker Sandboxes
      "fork" # the git UI
      "visual-studio-code"
      # "cursor"
      # "gitbutler"
      # "gitkraken"   # Fork is the git UI
      # "meld"        # Fork for diffs; git merge.tool is nvimdiff

      # -----------------------------------------------------------------------
      # API clients
      # -----------------------------------------------------------------------
      "bruno" # collections as files, so they live in git
      "postman" # API client and testing

      # -----------------------------------------------------------------------
      # Terminal
      # -----------------------------------------------------------------------
      "ghostty" # GPU-accelerated, native UI
      # "warp"        # AI-assisted terminal; closed-source, subscription-based

      # -----------------------------------------------------------------------
      # Browsers
      # -----------------------------------------------------------------------
      "firefox"
      "vivaldi" # Chromium-based, with a built-in mail client

      # -----------------------------------------------------------------------
      # Communication
      # -----------------------------------------------------------------------
      "discord" # voice and text chat
      "telegram" # messaging
      "thunderbird" # email client
      "zulip" # threaded team chat

      # -----------------------------------------------------------------------
      # Local LLM
      # -----------------------------------------------------------------------
      "lm-studio" # GUI to find, download and run local models
      "ollama-app" # local model runner

      # -----------------------------------------------------------------------
      # Privacy, security & remote access
      # -----------------------------------------------------------------------
      "lulu" # outbound firewall
      "proton-drive" # encrypted cloud storage
      "proton-mail" # mail and calendar client
      "proton-mail-bridge" # local IMAP/SMTP for desktop mail clients
      "protonvpn" # VPN client
      "tailscale-app" # WireGuard mesh VPN
      "yubico-authenticator" # YubiKey companion app

      # -----------------------------------------------------------------------
      # Window management & desktop UX
      # -----------------------------------------------------------------------
      "nikitabobko/tap/aerospace" # tiling window manager
      "betterdisplay" # display and resolution control
      "bettertouchtool" # input device customisation and automation
      "keyboard-maestro" # macro automation
      "maccy" # clipboard history
      "notunes" # stops Music hijacking the Play key
      "stats" # menu-bar system monitor
      "thaw" # menu bar manager
      # "voiceink" # voice control

      # -----------------------------------------------------------------------
      # System utilities
      # -----------------------------------------------------------------------
      "daisydisk" # disk space visualiser
      "frankea/whisky/whisky" # Wine wrapper for Windows apps (maintained fork)

      # -----------------------------------------------------------------------
      # Hardware & peripherals
      # -----------------------------------------------------------------------
      "bambu-studio" # 3D print slicer
      "canon-eos-utility" # tethering and control for Canon EOS bodies
      "elgato-stream-deck" # Stream Deck key configuration
      "insta360-link-controller" # Insta360 webcam control
      "obs" # capture and streaming
      "wacom-tablet" # tablet drivers
      # "openmtp" # Android file transfer

      # -----------------------------------------------------------------------
      # Documents & office
      # -----------------------------------------------------------------------
      # "adobe-acrobat-reader"
      "adobe-creative-cloud" # installer and launcher for the Adobe apps
      "mactex" # full TeX Live distribution
      "microsoft-office" # Office suite
      "obsidian" # Markdown knowledge base

      # -----------------------------------------------------------------------
      # Media & entertainment
      # -----------------------------------------------------------------------
      "plex" # home media player
      "roon" # music player
      "steam" # games
      # "spotify"
    ];
  };
}
