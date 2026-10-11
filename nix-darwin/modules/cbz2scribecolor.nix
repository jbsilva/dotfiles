{ pkgs, cbz2scribecolorSrc, ... }:
let
  ###########################################################################
  # vertiman/CBZ2ScribeColor
  #
  # Converts CBZ comics to sideloadable KFX books for the Kindle Scribe
  # Colorsoft, as `cbz2scribe` and `cbz2scribecolor`. Not in nixpkgs.
  #
  # The conversion itself runs through Calibre's KFX Output plugin, which in
  # turn needs Kindle Previewer 3. Both apps are casks in homebrew.nix. The
  # plugin is not: install it once from Calibre's Preferences > Plugins.
  #
  # importNpmLock reads package-lock.json from the source, so the npm
  # dependencies need no hash of their own and the flake input alone pins
  # everything.
  ###########################################################################
  cbz2scribecolor = pkgs.buildNpmPackage {
    pname = "cbz2scribecolor";
    # The date is in flake.lock, as for git-extra-commands.
    version = "0-unstable";

    src = cbz2scribecolorSrc;

    nodejs = pkgs.nodejs_24;
    npmDeps = pkgs.importNpmLock { npmRoot = cbz2scribecolorSrc; };
    inherit (pkgs.importNpmLock) npmConfigHook;

    meta = {
      description = "Convert CBZ comics to sideloadable KFX for Kindle Scribe Colorsoft";
      homepage = "https://github.com/vertiman/CBZ2ScribeColor";
      license = pkgs.lib.licenses.mit;
      mainProgram = "cbz2scribe";
      platforms = pkgs.lib.platforms.unix;
    };
  };
in
{
  environment.systemPackages = [ cbz2scribecolor ];
}
