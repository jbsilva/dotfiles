local g = vim.g
local o = vim.o

-------------------------------------------------------------------------------
--> Disable netrw (will use nvim-tree)
-------------------------------------------------------------------------------
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-------------------------------------------------------------------------------
--> Leader key
-------------------------------------------------------------------------------
g.mapleader = ' '
g.maplocalleader = ' '

------------------------------------------------------------------------------
--> True Color
------------------------------------------------------------------------------
o.termguicolors = true

------------------------------------------------------------------------------
--> Lower time in milliseconds to wait for a mapped sequence to complete
------------------------------------------------------------------------------
o.timeoutlen = 500

------------------------------------------------------------------------------
--> Lower updatetime
-- Used for CursorHold
------------------------------------------------------------------------------
o.updatetime = 300

------------------------------------------------------------------------------
--> Number of screen lines to keep above and below the cursor
------------------------------------------------------------------------------
o.scrolloff = 8

------------------------------------------------------------------------------
--> Mouse support enabled in all modes
------------------------------------------------------------------------------
o.mouse = 'a'

------------------------------------------------------------------------------
--> Editor UI
------------------------------------------------------------------------------
-- Show line numbers
o.number = true

-- Minimal number of columns to use for the line number
o.numberwidth = 4

-- Show the line number relative to the line with the cursor
o.relativenumber = true

-- Draw signcolumn (left of line numbers)
o.signcolumn = 'yes'

-- Highlight the current line
o.cursorline = true

-- Highlight the current column
-- o.cursorcolumn = true

-- Color columns 80 and 88
o.colorcolumn = '80,88,100'

-- Text wrap
o.wrap = true

-- Show symbol (↳) to indicate that line was wrapped
o.showbreak = '↳ '

-- Always report when lines are changed
o.report = 0

-- Allow move to next line. Not recommended
-- o.whichwrap = 'h,l,<,>,[,]'

------------------------------------------------------------------------------
--> Spaces and Tabs
------------------------------------------------------------------------------
-- Insert spaces instead of tabs
o.expandtab = true

-- o.smarttab = true
o.cindent = true

-- Use 4 spaces for each <Tab>
o.tabstop = 4

-- Number of spaces to use for each step of (auto)indent
o.shiftwidth = 4

-- Number of spaces that a <Tab> counts for while performing editing operations
o.softtabstop = 4

------------------------------------------------------------------------------
--> Represent tabs, trailing spaces and non-breakable space characters
------------------------------------------------------------------------------
o.list = true
vim.opt.listchars:append {
  -- space = '·',
  trail = '·',
  nbsp = '◇',
  tab = '→ ',
  extends = '▸',
  precedes = '◂',
  -- eol = '↴',
}

------------------------------------------------------------------------------
--> Searching
-- Ignore case in search patterns except if search pattern contains upper case
------------------------------------------------------------------------------
o.ignorecase = true
o.smartcase = true

------------------------------------------------------------------------------
--> Undo and backup
------------------------------------------------------------------------------
o.backup = false
o.writebackup = false
o.undofile = true
o.swapfile = false

------------------------------------------------------------------------------
--> Better buffer splitting
------------------------------------------------------------------------------
o.splitright = true
o.splitbelow = true

------------------------------------------------------------------------------
--> Custom filetypes
------------------------------------------------------------------------------
vim.filetype.add({
  extension = {
    eslintrc = 'json',
    prettierrc = 'json',
    conf = 'conf',
    mdx = 'markdown',
    mjml = 'html',
  },
  pattern = {
    ['.*%.env.*'] = 'sh',
    ['ignore$'] = 'conf',
  },
  filename = {
    ['yup.lock'] = 'yaml',
  },
})

