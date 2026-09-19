{
  config,
  lib,
  homebrewCore,
  homebrewCask,
  homebrewNikitabobko,
  homebrewDocker,
  homebrewFrankea,
  homebrewGromgit,
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
      "gromgit/homebrew-fuse" = homebrewGromgit;
    };
    mutableTaps = false;
  };

  # Homebrew 6's HOMEBREW_REQUIRE_TAP_TRUST refuses entries from untrusted
  # third-party taps. nix-darwin emits `trusted: true` on every brew and cask it
  # generates, which covers the fully-qualified ones below, so nothing needs to
  # write ~/.homebrew/trust.json.
  homebrew = {
    enable = true;
    # Upgrades are not part of activation. `just brew-upgrade` does them on
    # purpose; activation only installs and uninstalls to match the lists below.
    #
    # Leave `upgrade` off. It applies to every brew and cask below, and mactex,
    # microsoft-office, steam, adobe-creative-cloud and codeql are among them,
    # so turning it on lets a one-line change to any module pull gigabytes at a
    # moment nobody chose. Neither `just build` nor `just diff` shows a word of
    # it beforehand, which is what makes it worth keeping out of activation.
    #
    # `autoUpdate` has to stay off as well. It runs `brew update`, which fetches
    # inside each tap, and `mutableTaps = false` mounts them read-only out of
    # /nix/store, so it stops on `Permission denied`. A tap moves with its flake
    # input instead: `just update`, then `just switch`.
    #
    # `cleanup = "uninstall"` stays on: removing a line below should uninstall.
    onActivation = {
      autoUpdate = false;
      upgrade = false;
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
      "sonar-scanner" # SonarQube analysis client
      "hugo" # static site generator

      # -----------------------------------------------------------------------
      # Data
      # -----------------------------------------------------------------------
      "duckdb" # embedded analytical SQL
      "libpq" # psql and the client library, without a local server

      # -----------------------------------------------------------------------
      # Filesystems -- off until an NTFS disk needs writing to
      # -----------------------------------------------------------------------
      # Read-write NTFS, for external disks the Finder mounts read-only. The
      # gromgit/fuse tap stays in nix-homebrew.taps above, so enabling this is
      # three uncommented lines: here, and macfuse and mounty under casks.
      #
      # Do the cask by hand the first time round. The formula declares macFUSE
      # as a Requirement rather than a dependency, so Homebrew refuses to build
      # it until /usr/local/include/fuse.h is there and never installs the cask
      # itself, and the Brewfile lists every brew before any cask:
      #
      #   brew install --cask macfuse   # then approve the kext and reboot
      #   just switch
      # "gromgit/fuse/ntfs-3g-mac" # read-write NTFS driver for FUSE

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
      "wireguard-tools" # wg and wg-quick, to read and convert tunnel configs

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
      "claude" # Anthropic's desktop app
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
      "raycast" # launcher and command palette. The nixpkgs binary traps at launch
      "stats" # menu-bar system monitor
      "thaw" # menu bar manager
      # "voiceink" # voice control

      # -----------------------------------------------------------------------
      # System utilities
      # -----------------------------------------------------------------------
      "daisydisk" # disk space visualiser
      "frankea/whisky/whisky" # Wine wrapper for Windows apps (maintained fork)

      # -----------------------------------------------------------------------
      # Filesystems -- off with ntfs-3g-mac under brews, which explains the set
      # -----------------------------------------------------------------------
      # macFUSE ships a kernel extension. Installing the cask is only half of
      # it: macOS holds the kext until it is approved in System Settings >
      # Privacy & Security, and Apple silicon also wants Reduced Security in
      # recoveryOS. Both steps ask for a reboot.
      # "macfuse" # userspace filesystems, which ntfs-3g-mac builds on
      # "mounty" # menu bar app to remount an NTFS volume read-write

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
      # `brew bundle` installs most entries with one `brew install` command
      # that lists brews and casks together and passes no --cask. `mediainfo`
      # is also an alias of the media-info formula, so that command takes the
      # formula, reports success and leaves MediaInfo.app absent. `cleanup`
      # then removes that formula, because no brews entry declares it, so the
      # run leaves nothing behind to notice.
      #
      # An entry with non-empty `args` stays out of that shared command and
      # gets a `brew install --cask` of its own. appdir is already the
      # default, so it changes nothing else. A fully qualified name does not
      # help: bundle reduces it back to the bare token.
      #
      # Homebrew issue 23860, fixed by PR 23862 in 7.0.0 (2026-09-13).
      # nix-homebrew pins brew 6.0.22, so drop this entry for a plain
      # "mediainfo" once that pin passes 7.0.0.
      {
        name = "mediainfo"; # media file technical info
        args = {
          appdir = "/Applications";
        };
      }
      "plex" # home media player
      "roon" # music player
      "steam" # games
      # "spotify"
    ];
  };
}
