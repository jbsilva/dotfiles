{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    # AeroSpace
    homebrew-nikitabobko = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      nix-homebrew,
      home-manager,
      homebrew-core,
      homebrew-cask,
      homebrew-nikitabobko,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;

          # Define the user in nix-darwin (REQUIRED for home-manager)
          users.users.julio = {
            name = "julio";
            home = "/Users/julio";
          };

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            carapace # Multi-shell multi-command argument completer
            coreutils # basic file, shell and text manipulation utilities from GNU
            curl
            discord
            exiftool
            firefox
            gawk
            ghostty-bin
            git
            glow # Render markdown on the CLI
            gnugrep
            gnupg
            gnused
            gnutar
            hclfmt
            htop
            iina
            iperf
            jq
            loopwm # macOS Window management
            mas # Mac App Store command line interface
            neovim
            nixd
            nixfmt-rfc-style
            nodejs_24
            notion-app
            ollama
            p7zip
            raycast
            rsync
            shottr
            slack
            spotify
            swiftdefaultapps
            tailscale
            telegram-desktop
            terraform
            the-unarchiver
            vscode
            warp-terminal
            wezterm
            wget
            zellij
          ];

          # System-level fonts
          fonts.packages = with pkgs; [
            cascadia-code
            dejavu_fonts
            ibm-plex
            nerd-fonts.fira-code
            nerd-fonts.hack
            nerd-fonts.iosevka
            nerd-fonts.jetbrains-mono
            nerd-fonts.meslo-lg
            source-code-pro
          ];

          # Home Manager
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.julio =
              { pkgs, ... }:
              {
                # Home Manager basic configuration
                home.username = "julio";
                home.stateVersion = "24.05";

                # User specific apps, not available system-wide
                home.packages = with pkgs; [ ];

                programs = {
                  zsh = {
                    enable = true;
                    enableCompletion = true;
                    initContent = builtins.readFile ../.zshrc;
                  };

                  git = {
                    enable = true;
                    extraConfig = {
                      include = {
                        path = "/Users/julio/dotfiles/.gitconfig-global";
                      };
                      credential = {
                        helper = "osxkeychain";
                      };
                      gpg = {
                        program = "${pkgs.gnupg}/bin/gpg";
                      };
                      gitbutler = {
                        aiModelProvider = "lmstudio";
                        aiLMStudioModelName = "default";
                        aiLMStudioEndpoint = "http://127.0.0.1:1234";
                        gitbutlerCommitter = "0";
                      };
                    };
                  };

                  direnv = {
                    enable = true;
                    nix-direnv.enable = true;
                  };
                };

                # Docker CLI plugins setup using activation script
                home.activation.dockerPlugins = ''
                  echo "Setting up Docker CLI plugins..."

                  # Create plugins directory
                  mkdir -p ~/.docker/cli-plugins

                  # Create symlinks (runs after Homebrew is available)
                  if [ -f /opt/homebrew/bin/docker-compose ]; then
                    ln -sfn /opt/homebrew/bin/docker-compose ~/.docker/cli-plugins/docker-compose
                    echo "Linked docker-compose plugin"
                  fi

                  if [ -f /opt/homebrew/bin/docker-buildx ]; then
                    ln -sfn /opt/homebrew/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
                    echo "Linked docker-buildx plugin"
                  fi

                  # Install Docker Buildx
                  if command -v docker >/dev/null 2>&1; then
                    /opt/homebrew/bin/docker buildx install 2>/dev/null || true
                    echo "Docker buildx installed"
                  fi

                  echo "Docker CLI plugins setup complete"
                '';

                home.activation.setDefaultApps = ''
                  echo "Setting default applications using SwiftDefaultApps..."

                  SWDA_CMD="${pkgs.swiftdefaultapps}/bin/swda"
                  
                  if [ -x "$SWDA_CMD" ]; then
                    # Video files (IINA)
                    $SWDA_CMD setHandler --app "IINA" --UTI public.video
                    $SWDA_CMD setHandler --app "IINA" --UTI public.movie
                    $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg-4
                    $SWDA_CMD setHandler --app "IINA" --UTI public.avi
                    $SWDA_CMD setHandler --app "IINA" --UTI com.microsoft.windows-media-wmv
                    $SWDA_CMD setHandler --app "IINA" --UTI com.microsoft.windows-media-wma
                    $SWDA_CMD setHandler --app "IINA" --UTI com.microsoft.windows-media-wm
                    $SWDA_CMD setHandler --app "IINA" --UTI public.audio
                    $SWDA_CMD setHandler --app "IINA" --UTI public.au-audio  
                    $SWDA_CMD setHandler --app "IINA" --UTI public.ulaw-audio
                    $SWDA_CMD setHandler --app "IINA" --UTI public.enhanced-ac3-audio
                    $SWDA_CMD setHandler --app "IINA" --UTI com.audible.aa-audio
                    $SWDA_CMD setHandler --app "IINA" --UTI com.digidesign.sd2-audio
                    $SWDA_CMD setHandler --app "IINA" --UTI org.3gpp.adaptive-multi-rate-audio
                    $SWDA_CMD setHandler --app "IINA" --UTI public.audiovisual-content
                    $SWDA_CMD setHandler --app "IINA" --UTI public.avi
                    $SWDA_CMD setHandler --app "IINA" --UTI public.3gpp
                    $SWDA_CMD setHandler --app "IINA" --UTI public.3gpp2
                    $SWDA_CMD setHandler --app "IINA" --UTI public.dv-movie
                    $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg
                    $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg-2-video
                    $SWDA_CMD setHandler --app "IINA" --UTI com.apple.avurlasset-content
                    $SWDA_CMD setHandler --app "IINA" --UTI com.apple.quicktime-audio
                    $SWDA_CMD setHandler --app "IINA" --UTI com.apple.quicktime-movie
                    $SWDA_CMD setHandler --app "IINA" --UTI com.apple.mediaextension-content
                    $SWDA_CMD setHandler --app "IINA" --UTI public.mp3
                    $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg-4-audio
                    $SWDA_CMD setHandler --app "IINA" --UTI com.microsoft.waveform-audio
                    $SWDA_CMD setHandler --app "IINA" --UTI public.aiff-audio

                    # Browser (Vivaldi)
                    $SWDA_CMD setHandler --app "Vivaldi" --URL http
                    $SWDA_CMD setHandler --app "Vivaldi" --internet
                    $SWDA_CMD setHandler --app "Vivaldi" --UTI com.microsoft.internet-shortcut

                    # Text files and code (VS Code)
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.plain-text
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.source-code
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.script
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.property-list
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.json
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.xml
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.c-source
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.c-plus-plus-source
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.python-script
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.swift-source
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.objective-c-source
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.assembly-source
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.fortran-source
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.sun.java-source
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.json
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.yaml
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.geojson
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.ndjson
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.xml-property-list
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.ascii-property-list
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.shell-script
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.bash-script
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.zsh-script
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.python-script
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.perl-script
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.ruby-script
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.plain-text
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.utf8-plain-text
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.delimited-values-text
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.rtf
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.rtfd
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.patch-file
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.make-source
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.finalcutpro.xml
                    $SWDA_CMD setHandler --app "Visual Studio Code" --UTI org.khronos.collada.digital-asset-exchange

                    # Archive files (The Unarchiver)
                    $SWDA_CMD setHandler --app "The Unarchiver" --UTI public.zip-archive
                    $SWDA_CMD setHandler --app "The Unarchiver" --UTI public.tar-archive
                    $SWDA_CMD setHandler --app "The Unarchiver" --UTI org.gnu.gnu-zip-archive
                    $SWDA_CMD setHandler --app "The Unarchiver" --UTI com.microsoft.cab
                    $SWDA_CMD setHandler --app "The Unarchiver" --UTI com.microsoft.msi-installer

                    # Microsoft Office documents
                    $SWDA_CMD setHandler --app "Microsoft Word" --UTI com.microsoft.word.doc
                    $SWDA_CMD setHandler --app "Microsoft Word" --UTI org.openxmlformats.wordprocessingml.document
                    $SWDA_CMD setHandler --app "Microsoft Excel" --UTI com.microsoft.excel.xls
                    $SWDA_CMD setHandler --app "Microsoft Excel" --UTI org.openxmlformats.spreadsheetml.sheet

                    # PDF files (Adobe Acrobat Reader)
                    $SWDA_CMD setHandler --app "Adobe Acrobat" --UTI com.adobe.pdf

                    # echo "Refreshing Launch Services database..."
                    # # Kill and refresh Launch Services database
                    # /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
                    
                    # Wait for database to rebuild
                    sleep 3
                    
                    echo "Video default apps configuration completed"
                  else
                    echo "SwiftDefaultApps (swda: $SWDA_CMD) not found"
                  fi
                '';
              };
          };

          # Homebrew configuration
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "julio";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "nikitabobko/homebrew-tap" = homebrew-nikitabobko; # AeroSpace
            };

            # Enable fully-declarative tap management
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`
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
              "imagemagick"
              "libpq"
              "openssl"
            ];
            casks = [
              "adobe-acrobat-reader"
              "adobe-creative-cloud"
              "bambu-studio"
              "betterdisplay"
              "bettertouchtool"
              "elgato-stream-deck"
              "fork"
              "gitbutler"
              "keyboard-maestro"
              "lm-studio"
              "maccy"
              "microsoft-office"
              "nikitabobko/tap/aerospace"
              "obs"
              "obsidian"
              "plex"
              "stats"
              "transmission-remote-gui"
              "vivaldi"
            ];
          };

          # Nix configuration
          nix = {
            settings = {
              experimental-features = "nix-command flakes";
              extra-nix-path = "nixpkgs=flake:nixpkgs";
            };

            # Set up NIX_PATH for flakes
            nixPath = [
              "nixpkgs=${nixpkgs}"
              "darwin-config=${toString ./flake.nix}"
            ];

            # Set up the flake registry
            registry = {
              nixpkgs = {
                flake = nixpkgs;
              };
            };

            # Enable rosetta binaries
            extraOptions = ''
              extra-platforms = x86_64-darwin aarch64-darwin
            '';

            # Garbage collection
            # sudo nix-collect-garbage --delete-older-than 30d
            # sudo nix-store --optimise
            gc = {
              automatic = true;
              interval = {
                Hour = 3;
                Minute = 15;
              };
              options = "--delete-older-than 30d";
            };

            # Nix store optimization
            optimise = {
              automatic = true;
              interval = {
                Hour = 4;
                Minute = 15;
              };
            };

            # NixOS VM
            linux-builder.enable = true;
          };

          # Use Touch ID for sudo authentication
          security.pam.services.sudo_local.touchIdAuth = true;

          # System configuration
          system = {
            # User
            primaryUser = "julio";

            # Set Git commit hash for darwin-version
            configurationRevision = self.rev or self.dirtyRev or null;

            # Used for backwards compatibility
            # Read the changelog before changing: $ darwin-rebuild changelog
            stateVersion = 6;

            # System defaults
            defaults = {
              finder = {
                AppleShowAllFiles = true;
                AppleShowAllExtensions = true;
                _FXShowPosixPathInTitle = true;
                FXPreferredViewStyle = "clmv";
                FXDefaultSearchScope = "SCcf"; # Search current folder by default
                ShowStatusBar = true;
                FXEnableExtensionChangeWarning = false; # Don't ask about changing extensions
                ShowPathbar = true; # Allow editing path directly
                _FXSortFoldersFirst = true; # Keep folders on top
                QuitMenuItem = true; # Allow quitting Finder with Cmd+Q
                NewWindowTarget = "Home";
                # Show external drives and removable media on desktop
                ShowExternalHardDrivesOnDesktop = true;
                ShowHardDrivesOnDesktop = true;
                ShowMountedServersOnDesktop = true;
                ShowRemovableMediaOnDesktop = true;
              };

              loginwindow.LoginwindowText = "mbp@juliobs.com";

              # Screenshot settings
              screencapture = {
                location = "~/Pictures/Screenshots";
                type = "png"; # Change from default jpg
                disable-shadow = true; # Remove drop shadows
              };

              # Menu bar settings
              menuExtraClock = {
                ShowSeconds = true;
                ShowDayOfWeek = true;
                ShowDate = 1;
              };

              screensaver.askForPasswordDelay = 10;

              dock = {
                autohide = true;
                mru-spaces = false;
                persistent-apps = [
                  "/Applications/Vivaldi.app"
                  "/Applications/Nix Apps/Ghostty.app"
                  "/Applications/Nix Apps/WezTerm.app"
                ];
              };

              NSGlobalDomain = {
                ApplePressAndHoldEnabled = false; # Allow key repeat
                InitialKeyRepeat = 13; # Delay before repeating keystrokes
                KeyRepeat = 1; # Delay between repeated keystrokes upon holding a key
                AppleShowAllExtensions = true;
                AppleShowScrollBars = "Automatic";
                "com.apple.swipescrolldirection" = true; # Natural scrolling
                AppleKeyboardUIMode = 3; # Full keyboard access
                NSDocumentSaveNewDocumentsToCloud = false; # Save to local disk by default
                NSNavPanelExpandedStateForSaveMode = true; # Expanded save dialogs
                NSNavPanelExpandedStateForSaveMode2 = true; # Expanded save dialogs
                PMPrintingExpandedStateForPrint = true; # Expanded print dialogs
                PMPrintingExpandedStateForPrint2 = true; # Expanded print dialogs
              };

              trackpad = {
                Clicking = true;
                TrackpadThreeFingerDrag = true;
              };
            };
          };

          # The platform the configuration will be used on
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#M4
      darwinConfigurations."M4" = nix-darwin.lib.darwinSystem {
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          configuration
        ];
      };
    };
}
