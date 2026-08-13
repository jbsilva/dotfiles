{ pkgs, ... }:
{
  home.activation.setDefaultApps = ''
    echo "Setting default applications using SwiftDefaultApps..."

    SWDA_CMD="${pkgs.swiftdefaultapps}/bin/swda"

    # LaunchServices can be mid-rebuild right after Homebrew cask installs/upgrades
    # or login item changes earlier in activation, causing transient ERROR -10810.
    # Retry with backoff; continue on permanent errors (set -e safe).
    swda_set() {
      for delay in 1 2 4; do
        $SWDA_CMD "$@" && return 0
        sleep "$delay"
      done
      $SWDA_CMD "$@" || true
    }

    if [ -x "$SWDA_CMD" ]; then
      # Let LaunchServices settle after any preceding cask installs/login item churn
      sleep 3

      # Video files (IINA)
      swda_set setHandler --app "IINA" --UTI com.apple.avurlasset-content
      swda_set setHandler --app "IINA" --UTI com.apple.m4v-video
      swda_set setHandler --app "IINA" --UTI com.apple.mediaextension-content
      swda_set setHandler --app "IINA" --UTI com.apple.protected-mpeg-4-video
      swda_set setHandler --app "IINA" --UTI com.apple.quicktime-audio
      swda_set setHandler --app "IINA" --UTI com.apple.quicktime-movie
      swda_set setHandler --app "IINA" --UTI com.apple.tv.database
      swda_set setHandler --app "IINA" --UTI com.apple.tv.ite
      swda_set setHandler --app "IINA" --UTI com.apple.tv.library
      swda_set setHandler --app "IINA" --UTI com.apple.tv.movpkg
      swda_set setHandler --app "IINA" --UTI com.audible.aa-audio
      swda_set setHandler --app "IINA" --UTI com.digidesign.sd2-audio
      swda_set setHandler --app "IINA" --UTI com.microsoft.waveform-audio
      swda_set setHandler --app "IINA" --UTI com.microsoft.windows-media-wm
      swda_set setHandler --app "IINA" --UTI com.microsoft.windows-media-wma
      swda_set setHandler --app "IINA" --UTI com.microsoft.windows-media-wmv
      swda_set setHandler --app "IINA" --UTI org.3gpp.adaptive-multi-rate-audio
      swda_set setHandler --app "IINA" --UTI public.3gpp
      swda_set setHandler --app "IINA" --UTI public.3gpp2
      swda_set setHandler --app "IINA" --UTI public.aiff-audio
      swda_set setHandler --app "IINA" --UTI public.au-audio
      swda_set setHandler --app "IINA" --UTI public.audio
      swda_set setHandler --app "IINA" --UTI public.audiovisual-content
      swda_set setHandler --app "IINA" --UTI public.avi
      swda_set setHandler --app "IINA" --UTI public.dv-movie
      swda_set setHandler --app "IINA" --UTI public.enhanced-ac3-audio
      swda_set setHandler --app "IINA" --UTI public.m4v
      swda_set setHandler --app "IINA" --UTI public.matroska
      swda_set setHandler --app "IINA" --UTI public.movie
      swda_set setHandler --app "IINA" --UTI public.mp3
      swda_set setHandler --app "IINA" --UTI public.mpeg
      swda_set setHandler --app "IINA" --UTI public.mpeg-2-transport-stream
      swda_set setHandler --app "IINA" --UTI public.mpeg-2-video
      swda_set setHandler --app "IINA" --UTI public.mpeg-4
      swda_set setHandler --app "IINA" --UTI public.mpeg-4-audio
      swda_set setHandler --app "IINA" --UTI public.ulaw-audio
      swda_set setHandler --app "IINA" --UTI public.video
      swda_set setHandler --app "IINA" --UTI public.webm

      # Images (Preview)
      swda_set setHandler --app "Preview" --UTI com.apple.icns
      swda_set setHandler --app "Preview" --UTI com.canon.tif-raw-image
      swda_set setHandler --app "Preview" --UTI com.microsoft.bmp
      swda_set setHandler --app "Preview" --UTI com.microsoft.ico
      swda_set setHandler --app "Preview" --UTI com.microsoft.ppt.export.ext.jpg
      swda_set setHandler --app "Preview" --UTI com.microsoft.ppt.export.ext.png
      swda_set setHandler --app "Preview" --UTI com.microsoft.ppt.export.ext.tiff
      swda_set setHandler --app "Preview" --UTI public.camera-raw-image
      swda_set setHandler --app "Preview" --UTI public.gif
      swda_set setHandler --app "Preview" --UTI public.heic
      swda_set setHandler --app "Preview" --UTI public.heif
      swda_set setHandler --app "Preview" --UTI public.image
      swda_set setHandler --app "Preview" --UTI public.jpeg
      swda_set setHandler --app "Preview" --UTI public.png
      swda_set setHandler --app "Preview" --UTI public.tiff
      swda_set setHandler --app "Preview" --UTI public.webp

      swda_set setHandler --app "Vivaldi" --UTI public.svg-image

      # Browser (Vivaldi)
      swda_set setHandler --app "Vivaldi" --URL http
      swda_set setHandler --app "Vivaldi" --UTI com.microsoft.internet-shortcut
      swda_set setHandler --app "Vivaldi" --internet

      # Text files and code (VS Code)
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI com.apple.ascii-property-list
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI com.apple.finalcutpro.xml
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI com.apple.property-list
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI com.apple.rtfd
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI com.apple.xml-property-list
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI com.sun.java-source
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI net.daringfireball.markdown
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI org.khronos.collada.digital-asset-exchange
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.assembly-source
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.bash-script
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.c-plus-plus-source
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.c-source
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.delimited-values-text
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.fortran-source
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.geojson
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.json
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.make-source
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.ndjson
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.objective-c-source
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.patch-file
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.perl-script
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.plain-text
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.python-script
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.rtf
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.ruby-script
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.script
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.shell-script
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.source-code
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.swift-source
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.utf8-plain-text
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.xml
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.yaml
      swda_set setHandler --app "/Applications/Visual Studio Code.app" --UTI public.zsh-script

      # Archive files (The Unarchiver)
      swda_set setHandler --app "The Unarchiver" --UTI com.microsoft.cab
      swda_set setHandler --app "The Unarchiver" --UTI com.microsoft.msi-installer
      swda_set setHandler --app "The Unarchiver" --UTI org.gnu.gnu-zip-archive
      swda_set setHandler --app "The Unarchiver" --UTI public.tar-archive
      swda_set setHandler --app "The Unarchiver" --UTI public.zip-archive

      # Microsoft Office documents
      swda_set setHandler --app "Microsoft Excel" --UTI com.microsoft.excel.xls
      swda_set setHandler --app "Microsoft Excel" --UTI org.openxmlformats.spreadsheetml.sheet
      swda_set setHandler --app "Microsoft Word" --UTI com.microsoft.word.doc
      swda_set setHandler --app "Microsoft Word" --UTI org.openxmlformats.wordprocessingml.document

      # PDF files (Adobe Acrobat Reader)
      swda_set setHandler --app "Adobe Acrobat" --UTI com.adobe.pdf

      sleep 3

      echo "Default apps configuration completed"
    else
      echo "SwiftDefaultApps (swda: $SWDA_CMD) not found"
    fi
  '';
}
