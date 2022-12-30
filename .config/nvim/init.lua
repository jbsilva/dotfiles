-- ===================================================================
--        _  __             _
--       / |/ /__ ___ _  __(_)_ _
--      /    / -_) _ \ |/ / /  ' \             ( O O )
--     /_/|_/\__/\___/___/_/_/_/_/      ====oOO==(_)==OOo=====
--
-- File:         init.lua
-- Description:  Neovim config file. Ported from my old init.vim
-- Author:       Julio Batista Silva
-- Created:      2008 as init.vim
-- Last Change:  30 Dec 2022
--
-- Download: https://github.com/jbsilva/dotfiles
-- ===================================================================

if vim.g.vscode then
  require("vscode")
else
  require('options')
  require('autocmd')
  require('plugins')
  require('keybinds')
end
