# Homebrew formulae
# Requirements:
#    - Homebrew: ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#    - Command Line Tools for Xcodecode: `xcode-select --install`
#    - Brew Bundle: `brew tap Homebrew/bundle`
# Usage: `brew bundle`.
# Diff this file: $ brew bundle dump && grep -Fvxf dotfiles/Brewfile Brewfile > diff
# Update casks: brew cask install --force $(brew cask list)
# More brews: http://braumeister.org

# Taps
tap "caskroom/cask"
tap "caskroom/fonts"
tap "caskroom/versions"
tap "homebrew/binary"
tap "homebrew/bundle"
tap "homebrew/dupes"
tap "homebrew/fuse"
tap "homebrew/science"
tap "homebrew/x11"
tap "neovim/neovim"
tap "homebrew/python"
tap "homebrew/tex"
tap "homebrew/core"
tap "acrogenesis/macchanger"


cask "osxfuse"


# xquartz
cask "xquartz"


# GNU Core Utilities. Adicionar `$(brew --prefix coreutils)/libexec/gnubin` ao `$PATH`.
brew "coreutils"
brew "binutils"
brew "findutils", args: ["with-default-names"]
brew "moreutils"
brew "gawk"
brew "gnu-indent", args: ["with-default-names"]
brew "gnu-sed", args: ["with-default-names"]
brew "gnu-tar", args: ["with-default-names"]
brew "gnu-which", args: ["with-default-names"]
brew "gnutls"
brew "grep", args: ["with-default-names"]
brew "gzip"
brew "glib"

brew "rsync"
brew "ntfs-3g"


# Fonts
brew "freetype"
brew "fontconfig"
cask "font-inconsolata"
cask "font-terminus"
cask "font-hack-nerd-font"


# Programming

## C
#brew "gcc"
brew "astyle"
brew "autoconf"
brew "automake"
brew "cmake"
brew "ctags"


# Objective-C
brew "cocoapods"


## Python
## Python Virtual Environments
brew "pyenv"               


## Lua
brew "lua"


# Rust
brew "multirust"


## Javascript
brew "node"


## Java
cask "java"
brew "android-sdk"

## Swift
brew 'swiftlint'


# VCS
brew "git"
brew "git-extras"
brew "git-cal"
brew "git-flow"
brew "mercurial"
cask "sourcetree"

# Diff
#brew "meld"
brew "diff-so-fancy"


# Generate documentation for several programming languages
brew "doxygen"


# Network
#brew "aircrack-ng"
#brew "arp-scan"
#brew "b43-fwcutter"
brew "nmap"

## brute force WPA/WPA2
#brew "reaver"              

## sniffer, MITM
#brew "ettercap"            

## Packet analyzer
cask "wireshark"       

# Correct mistyped console commands
#brew "thefuck"

# Jump to frequently used directories
#brew "autojump"

# Data compression with high compression ratio
#brew "xz"

brew "ack"

brew "readline"

# Tool for browsing source code
#brew "cscope"

# Select default apps for documents and URL schemes on OS X
brew "duti"

# Prints strings as ASCII art
#brew "figlet"

# GNU database manager
brew "gdbm"

brew "gettext"

brew "pcre"
brew "pkg-config"
brew "libtasn1"

brew "libtool"

brew "htop-osx"

brew "libtiff"
brew "webp"
brew "libyaml"
brew "rename"
brew "renameutils"
brew "tree"
brew "unoconv", args: ["HEAD"]
brew "watch"
brew "wdiff", args: ["with-gettext"]
brew "wget", args: ["with-iri"]
brew "byobu"
brew "media-info"


# Shell
brew "bash"
brew "zsh"
brew "zsh-completions"
brew "shellcheck"

# Fuzzy Finder
brew "fzf"


# Ruby
brew "ruby"


# Archive
#brew "unrar"
brew "homebrew/binary/rar"
brew "p7zip"
cask "the-unarchiver"
brew "homebrew/dupes/unzip"



cask "android-file-transfer"
cask "calibre"
cask "dropbox"

# Browser
cask "firefox"
cask "google-chrome"

cask "insomniax"
cask "iterm2"

# Game
cask "steam"


# Downloader
cask "transmission"

# Image Editor
#cask "inkscape"
#cask "gimp"
cask "picasa"

cask "flux"

# Screen Capture
cask "licecap"


# Multimedia
brew "libpng"
brew "imagemagick", args: ["with-webp"]
brew "ffmpeg"
brew "flac"
cask "spotify"
cask "vlc"
brew "youtube-dl"
brew "jpeg"
brew "exiv2"
#brew "lame"
#cask "audacity"
#cask "flash-player"

## Decode/convert/play lossless audio
cask "xld"

## Tag editor for MP3, OGG, FLAC...
#cask "kid3"                       

## PF firewall frontend
#cask "icefloor"


# VPN
brew "openconnect"
#cask "private-internet-access"
#cask "tunnelblick"


# TOR
#cask "torbrowserbundle"


# Cloud Storage
cask "google-drive"


# IDE
cask "android-studio"
cask "appcode"


# Static site generator
brew 'hugo'


# SQL
brew "sqlmap"

## Postgres
#brew "pgbadger"
#brew "pgbouncer"
#brew "pgcli"
#brew "pgformatter"
#brew "postgis"
#brew "postgresql"
#cask "pgadmin3"


## Mysql
brew "mysql"


### MySQL GUI
cask "mysqlworkbench"              


## SQLite
brew "sqlite", args: ["with-functions"]
cask "sqlitebrowser"


## MongoDB
cask "mongodb"


# Message / Chat
brew "irssi"
cask "skype"
cask "telegram"
cask "rocket-chat"
#brew "libidn"


# DjVu viewer
cask "djview"


# Gettext Translations Editor
#cask "poedit"


# LaTeX
cask "mactex"
cask "texmaker"
brew "homebrew/tex/latex-mk"


# Bibliography reference
cask "jabref"
cask "bibdesk"


# Markdown editor
#cask "macdown"                     
#cask "haroopad"


## Interpreter for PostScript and PDF
brew "ghostscript"


# Unicode Keyboard Layout Editor
#cask "ukelele"                    


# VM
# cask "virtualbox"                  
# cask "virtualbox-extension-pack"


# Tablet drivers
#cask "wacom-bamboo-tablet"


# Open Microsoft Compiled HTML Help files
cask "ichm"


# Convert MS Word to text
brew "docx2txt"


# Cryptography
brew "ssh-copy-id"
brew "openssl"
brew "mcrypt"
brew "gpg"
cask "gpgtools-beta"
cask "keybase"
brew "gpg-agent"
brew "gnupg2"

brew "john-jumbo"

## Generate wordlist
brew "crunch"

## Low-level cryptographic library
#brew "nettle"

# Jing - Record videos
cask "jing"


# Swap ESC and CapsLock
cask "karabiner-elements"

# Screen resolution
cask "switchresx"


# Editor
#brew "neovim/neovim/neovim", args: ["HEAD"]
cask "vimr"
