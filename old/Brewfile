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
#tap "caskroom/cask"
#tap "caskroom/fonts"
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


# Filesystem
#cask "osxfuse"
#brew "ext4fuse"
#brew "ntfs-3g"

brew "rsync"


# GNU Core Utilities. Adicionar `$(brew --prefix coreutils)/libexec/gnubin` ao `$PATH`.
brew "coreutils"
brew "binutils", link: true
brew "findutils", args: ["with-default-names"]
brew "moreutils"
brew "gawk"
brew "gnu-indent", args: ["with-default-names"]
brew "gnu-sed", args: ["with-default-names"]
brew "gnu-tar", args: ["with-default-names"]
brew "gnu-which", args: ["with-default-names"]
#brew "gnutls"
brew "grep", args: ["with-default-names"]
brew "gzip"
#brew "glib"


# xquartz
cask "xquartz"


# math
#brew "gnu-plot"

# Flashcards
# cask "anki"


# Fonts
#brew "freetype"
#brew "fontconfig"
#cask "font-inconsolata"
#cask "font-terminus"
cask "font-hack-nerd-font"


# Programming

## C
#brew "gcc"
#brew "astyle"
#brew "autoconf"
#brew "automake"
brew "cmake"
brew "ctags"


# Objective-C
#brew "cocoapods"


## Python
## Python Virtual Environments
#brew "pyenv"               
#cask "anaconda"
cask "pycharm"


# R
cask "r-app"
cask "rstudio"


cask "silverlight"
#cask "timer"


## Lua
brew "lua"


# Rust
#brew "multirust"


## Javascript
#brew "node"

# Json processor
#brew "jq"


## Java
cask "java"
#brew "jenv"
#brew "android-sdk"

## Swift
#brew 'swiftlint'


# VCS
#brew "mercurial"
brew "git"
brew "git-extras"
brew "git-cal"
brew "git-flow"
cask "sourcetree"
#brew "mergepbx" # A tool for merging Xcode project files in git


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
#cask "wireshark"       

# Correct mistyped console commands
#brew "thefuck"

# Jump to frequently used directories
#brew "autojump"

# Data compression with high compression ratio
#brew "xz"

brew "ack"

#brew "readline"

# Tool for browsing source code
#brew "cscope"

# Select default apps for documents and URL schemes on OS X
brew "duti"

# Prints strings as ASCII art
#brew "figlet"

# GNU database manager
#brew "gdbm"

brew "gettext"

brew "pcre"
brew "pkg-config"
#brew "libtasn1"

brew "libtool"

# Task manager
brew "htop"

#brew "libtiff"
#brew "webp"
brew "libyaml"
brew "rename"
brew "renameutils"
brew "tree"
brew "unoconv", args: ["HEAD"]
brew "watch"
brew "wdiff"
brew "wget"
brew "byobu"
brew "media-info"
brew "pv"


# Shell
brew "bash"
brew "zsh"
brew "zsh-completions"
#brew "shellcheck"

# Zsh Plugin Manager
brew "zplug"

# Tmux
#brew "tmux"
#brew "tmuxinator-completion"

# Terminal
cask "iterm2"


# Fuzzy Finder
brew "fzf"


# Emojify - Emoji on the command line
brew "emojify"


# Ruby
brew "ruby", link: true


# Archive
brew "unrar"
brew "unzip"
#brew "homebrew/binary/rar"
brew "p7zip"
cask "the-unarchiver"
#brew "homebrew/dupes/unzip"

cask "calibre"

# Browser
cask "firefox"
cask "google-chrome"

# Command line HTTP client - https://httpie.org/doc
#brew "httpie"


# Games
cask "steam"


# Downloader
cask "transmission"


# Image Editor
#cask "inkscape"
#cask "gimp"
#cask "picasa"

# OpenCV
# brew "opencv"


# Disable lid/idle sleep
cask "insomniax"
#cask "keepingyouawake"


# Filter the bright blue colors
#cask "flux"


# Screen Capture
#cask "licecap"


# Jing - Record videos
#cask "jing"


# Multimedia
#brew "libpng"
brew "imagemagick"
brew "ffmpeg"
brew "flac"
cask "spotify"
cask "vlc"
brew "youtube-dl"
#brew "jpeg"
brew "exiv2"
brew "exempi"
brew "exiftool"
#brew "lame"
#cask "audacity"
#cask "flash-player"

# SVG
#cask "inkscape"

## Decode/convert/play lossless audio
#cask "xld"

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


# AWS
brew "awscli"


# Cloud Storage
cask "google-drive"
cask "dropbox"


# IDE
#cask "appcode"

# Android
#cask "android-studio"
#cask "android-platform-tools"
#cask "android-file-transfer"


# Arduino
#cask "arduino"


# Static site generator
brew "hugo"


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
#cask "mysqlworkbench"              


## SQLite
#brew "sqlite", args: ["with-functions"]
#cask "sqlitebrowser"
#cask "db-browser-for-sqlite"


## MongoDB
cask "mongodb"


# Message / Chat
#brew "irssi"
cask "skype"
cask "telegram"
#cask "rocket-chat"
#brew "libidn"


# DjVu viewer
cask "djview"


# Gettext Translations Editor
#cask "poedit"


# LaTeX
#cask "mactex"
#cask "texmaker"
#brew "homebrew/tex/latex-mk"


# Bibliography reference
#cask "jabref"
#cask "bibdesk"
#brew "bib-tool"


# Markdown editor
#cask "macdown"                     
#cask "haroopad"


# Regular expressions library
#brew "pcre"


## Interpreter for PostScript and PDF
brew "ghostscript"


# VM
# cask "virtualbox"                  
# cask "virtualbox-extension-pack"


# Tablet drivers
#cask "wacom-bamboo-tablet"


# Open Microsoft Compiled HTML Help files
#cask "ichm"


# Convert MS Word to text
#brew "docx2txt"


# Cryptography
cask "veracrypt"
brew "ssh-copy-id"
#brew "openssl"
brew "mcrypt"
#brew "gpg"
cask "gpgtools-beta"
cask "keybase"
brew "gpg-agent"
#brew "gnupg2"
#brew "mhash"
#brew "nettle"
brew "oath-toolkit"

brew "sshfs"
brew "sshpass"

# Crack passwords
#brew "john-jumbo"


## Generate wordlist
#brew "crunch"


# Remap keyboard (swap ESC with CapsLock)
cask "karabiner-elements"

# Unicode Keyboard Layout Editor
#cask "ukelele"                    


# Screen resolution
cask "switchresx"


# Editor
brew "neovim"
#cask "vimr"

#cask "wine-devel"
