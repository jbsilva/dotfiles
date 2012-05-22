"===================================================================
"
"                      ( O O )
"               ====oOO==(_)==OOo=====
"
" File:         ~/.vimrc
" Description:  Arquivo de configuração do VIM
" Author:       Julio
" Created:      2008
" Last Change:  Sat 26 Nov 2011 17:00
" Licence:
"           Copyright (c) 2008-2011 Julio B. Silva <julio@juliobs.com>
"                       All Rights Reserved
"
"           This program is free software. It comes without any warranty, to
"           the extent permitted by applicable law. You can redistribute it
"           and/or modify it under the terms of the Do What The Fuck You Want
"           To Public License, Version 2, as published by Sam Hocevar. See
"           http://sam.zoy.org/wtfpl/COPYING for more details.
"
" Download:
"       http://www.comp.ufscar.br/~jbsilva/files/dotfiles/.vimrc
"       http://www.juliobs.com/dotfiles/.vimrc
"
" Distro: Arch Linux
"
" Inspirações:
"   http://www.hermann-uwe.de/files/vimrc
"   http://amix.dk/vim/vimrc.html
"   http://nion.modprobe.de/setup/vimrc
"   http://www.jukie.net/~bart/conf/vimrc
"   http://zi0r.com/2009/11/08/vimrc.html
"===================================================================

"------------------------------------------------------------------------------
" => Usa as configurações do VIM e não do VI
"    Deve aparecer antes das outras configurações
"------------------------------------------------------------------------------
set nocompatible

"------------------------------------------------------------------------------
" => Carrega os plugins do Vundle
"------------------------------------------------------------------------------
source $HOME/.vim/vundle_plugins.vim

"------------------------------------------------------------------------------
" => Carrega o restante das configurações
"------------------------------------------------------------------------------
source $HOME/.vim/settings.vim
