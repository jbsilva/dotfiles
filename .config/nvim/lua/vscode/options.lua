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

