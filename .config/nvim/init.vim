"===================================================================
"
"                      ( O O )
"               ====oOO==(_)==OOo=====
"
" File:         init.vim
" Description:  Neovim config file
" Author:       Julio Batista Silva
" Created:      2008
" Last Change:  05 Jun 2021
" Licence:
"           Copyright (c) 2008-2021 Julio Batista Silva <vim@juliobs.com>
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
" => Constants
" Different ways to define a variable. Eg.:
"   let user = 'Julio Batista Silva'                    -- String
"   let user = expand($USER_FULLNAME)                   -- Environment variable
"   let user = system('git config -z --get user.name')  -- Shell command
"------------------------------------------------------------------------------
let g:DOTFILES = escape(expand('%:p:h:h'), ' ') "dotfiles/.config
let g:VIMDIR = escape(expand('%:p:h'), ' ')     "dotfiles/.config/nvim
let g:INITFILE = escape(expand('%:p'), ' ')     "dotfiles/.config/nvim/init.vim
let g:TEMPLATES = g:VIMDIR . '/templates'       "dotfiles/.config/nvim/templates
let g:VIMSETTINGS = g:VIMDIR . '/settings.vim'  "dotfiles/.config/nvim/settings.vim
let g:PLUGINS = g:VIMDIR . '/plugins.vim'       "dotfiles/.config/nvim/plugins.vim

"------------------------------------------------------------------------------
" => Leader key
"------------------------------------------------------------------------------
let mapleader=','

"------------------------------------------------------------------------------
" => Vim-plug Plugins
"------------------------------------------------------------------------------
exec 'source' g:PLUGINS

"------------------------------------------------------------------------------
" => Load the settings
"------------------------------------------------------------------------------
exec 'source' g:VIMSETTINGS

