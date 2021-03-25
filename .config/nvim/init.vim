"===================================================================
"
"                      ( O O )
"               ====oOO==(_)==OOo=====
"
" File:         init.vim
" Description:  Arquivo de configuração do Nvim
" Author:       Julio Batista Silva
" Created:      2008
" Last Change:  25 Mar 2021
" Licence:
"           Copyright (c) 2008-2021 Julio Batista Silva <julio@juliobs.com>
"                       All Rights Reserved
"
"           This program is free software. It comes without any warranty, to
"           the extent permitted by applicable law. You can redistribute it
"           and/or modify it under the terms of the Do What The Fuck You Want
"           To Public License, Version 2, as published by Sam Hocevar. See
"           http://sam.zoy.org/wtfpl/COPYING for more details.
"
" Download: https://github.com/jbsilva/dotfiles
"===================================================================

"------------------------------------------------------------------------------
" => Empty config for VSCode
"------------------------------------------------------------------------------
if exists('g:vscode')
    finish
endif


"------------------------------------------------------------------------------
" => Leader key
"------------------------------------------------------------------------------
let mapleader=','


"------------------------------------------------------------------------------
" => Vim-plug
"------------------------------------------------------------------------------
source $XDG_CONFIG_HOME/nvim/vimplug_plugins.vim


"------------------------------------------------------------------------------
" => Load the settings
"------------------------------------------------------------------------------
source $XDG_CONFIG_HOME/nvim/settings.vim

