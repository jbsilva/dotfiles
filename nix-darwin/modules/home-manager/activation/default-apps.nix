{ pkgs, ... }:
{
  home.activation.setDefaultApps = ''
    echo "Setting default applications using SwiftDefaultApps..."

    SWDA_CMD="${pkgs.swiftdefaultapps}/bin/swda"

    if [ -x "$SWDA_CMD" ]; then
      # Video files (IINA)
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.avurlasset-content
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.m4v-video
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.mediaextension-content
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.protected-mpeg-4-video
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.quicktime-audio
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.quicktime-movie
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.tv.database
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.tv.ite
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.tv.library
      $SWDA_CMD setHandler --app "IINA" --UTI com.apple.tv.movpkg
      $SWDA_CMD setHandler --app "IINA" --UTI com.audible.aa-audio
      $SWDA_CMD setHandler --app "IINA" --UTI com.digidesign.sd2-audio
      $SWDA_CMD setHandler --app "IINA" --UTI com.microsoft.waveform-audio
      $SWDA_CMD setHandler --app "IINA" --UTI com.microsoft.windows-media-wm
      $SWDA_CMD setHandler --app "IINA" --UTI com.microsoft.windows-media-wma
      $SWDA_CMD setHandler --app "IINA" --UTI com.microsoft.windows-media-wmv
      $SWDA_CMD setHandler --app "IINA" --UTI org.3gpp.adaptive-multi-rate-audio
      $SWDA_CMD setHandler --app "IINA" --UTI public.3gpp
      $SWDA_CMD setHandler --app "IINA" --UTI public.3gpp2
      $SWDA_CMD setHandler --app "IINA" --UTI public.aiff-audio
      $SWDA_CMD setHandler --app "IINA" --UTI public.au-audio
      $SWDA_CMD setHandler --app "IINA" --UTI public.audio
      $SWDA_CMD setHandler --app "IINA" --UTI public.audiovisual-content
      $SWDA_CMD setHandler --app "IINA" --UTI public.avi
      $SWDA_CMD setHandler --app "IINA" --UTI public.dv-movie
      $SWDA_CMD setHandler --app "IINA" --UTI public.enhanced-ac3-audio
      $SWDA_CMD setHandler --app "IINA" --UTI public.m4v
      $SWDA_CMD setHandler --app "IINA" --UTI public.matroska
      $SWDA_CMD setHandler --app "IINA" --UTI public.movie
      $SWDA_CMD setHandler --app "IINA" --UTI public.mp3
      $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg
      $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg-2-transport-stream
      $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg-2-video
      $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg-4
      $SWDA_CMD setHandler --app "IINA" --UTI public.mpeg-4-audio
      $SWDA_CMD setHandler --app "IINA" --UTI public.ulaw-audio
      $SWDA_CMD setHandler --app "IINA" --UTI public.video
      $SWDA_CMD setHandler --app "IINA" --UTI public.webm

      # Browser (Vivaldi)
      $SWDA_CMD setHandler --app "Vivaldi" --URL http
      $SWDA_CMD setHandler --app "Vivaldi" --UTI com.microsoft.internet-shortcut
      $SWDA_CMD setHandler --app "Vivaldi" --internet

      # Text files and code (VS Code)
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.ascii-property-list
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.finalcutpro.xml
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.property-list
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.rtfd
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.apple.xml-property-list
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI com.sun.java-source
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI org.khronos.collada.digital-asset-exchange
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.assembly-source
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.bash-script
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.c-plus-plus-source
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.c-source
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.delimited-values-text
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.fortran-source
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.geojson
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.json
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.make-source
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.ndjson
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.objective-c-source
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.patch-file
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.perl-script
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.plain-text
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.python-script
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.rtf
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.ruby-script
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.script
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.shell-script
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.source-code
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.swift-source
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.utf8-plain-text
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.xml
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.yaml
      $SWDA_CMD setHandler --app "Visual Studio Code" --UTI public.zsh-script

      # Archive files (The Unarchiver)
      $SWDA_CMD setHandler --app "The Unarchiver" --UTI com.microsoft.cab
      $SWDA_CMD setHandler --app "The Unarchiver" --UTI com.microsoft.msi-installer
      $SWDA_CMD setHandler --app "The Unarchiver" --UTI org.gnu.gnu-zip-archive
      $SWDA_CMD setHandler --app "The Unarchiver" --UTI public.tar-archive
      $SWDA_CMD setHandler --app "The Unarchiver" --UTI public.zip-archive

      # Microsoft Office documents
      $SWDA_CMD setHandler --app "Microsoft Excel" --UTI com.microsoft.excel.xls
      $SWDA_CMD setHandler --app "Microsoft Excel" --UTI org.openxmlformats.spreadsheetml.sheet
      $SWDA_CMD setHandler --app "Microsoft Word" --UTI com.microsoft.word.doc
      $SWDA_CMD setHandler --app "Microsoft Word" --UTI org.openxmlformats.wordprocessingml.document

      # PDF files (Adobe Acrobat Reader)
      $SWDA_CMD setHandler --app "Adobe Acrobat" --UTI com.adobe.pdf

      sleep 3

      echo "Default apps configuration completed"
    else
      echo "SwiftDefaultApps (swda: $SWDA_CMD) not found"
    fi
  '';
}
