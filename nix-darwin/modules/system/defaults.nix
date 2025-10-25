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
        # "/Applications/Nix Apps/WezTerm.app"
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
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };
}
