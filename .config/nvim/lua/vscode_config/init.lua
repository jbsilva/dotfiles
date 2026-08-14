-------------------------------------------------------------------------------
--> Neovim driving VS Code (vscode-neovim)
--
-- VS Code owns the UI here, so nearly nothing in options.lua applies: no
-- statusline, no colours, no plugins, no file explorer. Only the editing
-- behaviour Neovim is still responsible for gets set.
--
-- Named vscode_config, not vscode: vscode-neovim ships its own `vscode` module
-- (vscode.action(), vscode.eval(), vscode.notify()). This directory sits
-- earlier on the runtimepath, so a `vscode` here would shadow it and put the
-- extension's API out of reach for everything in the session.
-------------------------------------------------------------------------------
local g = vim.g
local o = vim.o

-------------------------------------------------------------------------------
--> Leader key
-------------------------------------------------------------------------------
g.mapleader = ' '
g.maplocalleader = ' '

------------------------------------------------------------------------------
--> Searching
-- Ignore case in search patterns except if search pattern contains upper case
------------------------------------------------------------------------------
o.ignorecase = true
o.smartcase = true
