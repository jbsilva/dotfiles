{ ... }:
{
  system.defaults = {
    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXPreferredViewStyle = "clmv";
      FXDefaultSearchScope = "SCcf";
      ShowStatusBar = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathbar = true;
      _FXSortFoldersFirst = true;
      QuitMenuItem = true;
      NewWindowTarget = "Home";
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
    };

    # Finder writes a .DS_Store into every network folder it opens. Synology's
    # SMB cannot keep a resource fork inside the file, so it puts one beside it
    # as @eaDir/.DS_Store@SynoResource, and the NAS fills up with @eaDir nobody
    # reads. This stops the cause rather than sweeping the shares afterwards.
    #
    # Network volumes only. Local disks keep their .DS_Store, so only shares
    # forget their per-folder view style, sort order and window size.
    CustomUserPreferences."com.apple.desktopservices".DSDontWriteNetworkStores = true;

    loginwindow.LoginwindowText = "mbp@juliobs.com";

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

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
        "/Applications/Ghostty.app"
        "/System/Applications/Mail.app"
      ];
    };

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 13;
      KeyRepeat = 1;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Automatic";
      "com.apple.swipescrolldirection" = true;
      AppleKeyboardUIMode = 3;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      NSAutomaticPeriodSubstitutionEnabled = false; # double-space → period
      NSAutomaticCapitalizationEnabled = false; # auto capitalize
      NSAutomaticDashSubstitutionEnabled = false; # smart dashes
      NSAutomaticQuoteSubstitutionEnabled = false; # smart quotes
      NSAutomaticSpellingCorrectionEnabled = true; # spell correction
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };

  system.startup.chime = false;
}
