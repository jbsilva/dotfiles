# Homebrew formulae - OS X El Capitan
# Requirements:
#    - Homebrew: ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#    - Command Line Tools for Xcodecode: `xcode-select --install`
#    - Brew Bundle: `brew tap Homebrew/bundle`
# Usage: `brew bundle`.
# Diff this file: $ brew bundle dump && grep -Fvxf dotfiles/Brewfile Brewfile > diff
# Update casks: brew cask install --force $(brew cask list)
# More brews: http://braumeister.org

# Taps
tap 'caskroom/cask'
tap 'caskroom/fonts'
tap 'homebrew/bundle'
tap 'homebrew/dupes'
tap 'homebrew/fuse'
tap 'homebrew/science'
tap 'homebrew/x11'
tap 'neovim/neovim'
#tap 'homebrew/php'
tap 'homebrew/python'


# osxfuse deve ser instalado antes de ntfs-3g
cask 'osxfuse'


# xquartz
cask 'xquartz'


# GNU Core Utilities. Adicionar `$(brew --prefix coreutils)/libexec/gnubin` ao `$PATH`.
brew 'coreutils'
brew 'binutils'
brew 'findutils', args: ['with-default-names']
brew 'moreutils'
brew 'gawk'
brew 'gnu-indent', args: ['with-default-names']
brew 'gnu-sed', args: ['with-default-names']
brew 'gnu-tar', args: ['with-default-names']
brew 'gnu-which', args: ['with-default-names']
brew 'gnupg'
brew 'gnutls'
brew 'homebrew/dupes/grep', args: ['with-default-names']
brew 'homebrew/dupes/gzip'

brew 'homebrew/dupes/rsync'
brew 'homebrew/dupes/screen'
brew 'homebrew/dupes/unzip'
brew 'homebrew/fuse/ntfs-3g'


# Fonts
brew 'freetype'
brew 'fontconfig'
cask 'font-inconsolata'
cask 'font-terminus'


# C
brew 'gcc'
brew 'astyle'
brew 'autoconf'
brew 'automake'
brew 'boost'
brew 'cmake'
brew 'ctags'
brew 'icu4c'


# python
brew 'python'
brew 'python3'
brew 'pypy'
brew 'pypy3'


# Java
cask 'java'
brew 'android-sdk'




# VCS
brew 'git'
brew 'git-extras'
brew 'git-cal'
brew 'git-flow'
brew 'mercurial'
#brew 'meld'             # diff


# Network
#brew 'aircrack-ng'
#brew 'arp-scan'
#brew 'b43-fwcutter'
brew 'nmap'
#brew 'reaver'               # brute force WPA/WPA2
#brew 'subnetcalc'
#brew 'ettercap'             # sniffer, MITM
#cask 'wireshark'            # Packet analyzer


# postgres
#brew 'pgbadger'
#brew 'pgbouncer'
#brew 'pgcli'
#brew 'pgformatter'
#brew 'postgis'
#brew 'postgresql'
#cask 'pgadmin3'


brew 'ffmpeg'
brew 'thefuck'
brew 'autojump'
brew 'ack'
brew 'xz'
brew 'readline'
brew 'bash'
brew 'gmp'
brew 'cscope'
brew 'docbook'
brew 'docbook-xsl'
brew 'duti'
brew 'figlet'
brew 'libpng'
brew 'gdbm'
brew 'gettext'
brew 'pcre'
brew 'pkg-config'
brew 'libtasn1'
brew 'nettle'
brew 'neovim/neovim/neovim', args: ['HEAD']
brew 'libtool'
brew 'htop-osx'
brew 'jpeg'
brew 'libtiff'
brew 'webp'
brew 'imagemagick', args: ['with-webp']
brew 'libyaml'
brew 'sqlite'
brew 'makedepend'
brew 'openssl'
brew 'p7zip'
brew 'rename'
brew 'renameutils'
brew 'ruby'
brew 'sqlmap'
brew 'ssh-copy-id'
brew 'tree'
brew 'unoconv', args: ['HEAD']
brew 'unrar'
brew 'watch'
brew 'wdiff', args: ['with-gettext']
brew 'wget', args: ['with-iri']
brew 'youtube-dl', args: ['HEAD']
brew 'zsh'
brew 'zsh-completions'
brew 'tmux'
brew 'byobu'
brew 'mcrypt'
brew 'media-info'
brew 'multirust'
brew 'mysql'
brew 'nmap'


cask 'android-file-transfer'
cask 'calibre'
cask 'dropbox'
cask 'firefox'
cask 'google-chrome'
cask 'insomniax'
cask 'iterm2'
cask 'picasa'
cask 'seil'
cask 'spotify'
cask 'steam'
cask 'the-unarchiver'
cask 'transmission'
cask 'vlc'
cask 'ukelele' # Modify Keyboard Layouts

#cask 'inkscape'
#cask 'gimp'

cask 'jabref'
cask 'bibdesk'

cask 'flux'
cask 'licecap'

cask 'telegram'
#brew 'libidn'

#brew 'gpg'
#brew 'homebrew/x11/meld
#brew 'lame'
#cask 'audacity'
#cask 'flash-player'
#cask 'icefloor'
#cask 'kid3'                            # Tag editor for MP3, OGG, FLAC...
cask 'xld'                              # Decode/convert/play lossless audio
#cask 'poedit'

cask 'private-internet-access'          # VPN
#cask 'tunnelblick'                     # VPN

#cask 'silverlight'
#cask 'torbrowserbundle'
#cask 'google-drive'
cask 'android-studio'
cask 'djview'
cask 'pandoc'                           # Document converter

cask 'mactex'
cask 'texmaker'

#cask 'haroopad'                        # Markdown editor
cask 'macdown'                          # Markdown editor

cask 'mysqlworkbench'                   # MySQL GUI
#cask 'ukelele'                         # Unicode Keyboard Layout Editor

cask 'virtualbox'                       # VM
cask 'virtualbox-extension-pack'        # VM tools

cask 'wacom-bamboo-tablet'              # Tablet drivers
cask 'ichm'                             # Open Microsoft Compiled HTML Help files
