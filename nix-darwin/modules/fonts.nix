{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    cascadia-code
    dejavu_fonts
    ibm-plex
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    source-code-pro
  ];
}
