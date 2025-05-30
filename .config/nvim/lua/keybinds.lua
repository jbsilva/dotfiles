-------------------------------------------------------------------------------
-- Keybinds
-- 
--  Use `:verbose map <KEYS>` to check if/where a shortcut is already in use
-------------------------------------------------------------------------------

local remap = require("mapmodes")
local noremap = remap.noremap
local inoremap = remap.inoremap
local vnoremap = remap.vnoremap
local nnoremap = remap.nnoremap
local xnoremap = remap.xnoremap
local onoremap = remap.onoremap

-------------------------------------------------------------------------------
--> Don't move to next match with '*'
-------------------------------------------------------------------------------
nnoremap('*', '*N')

-------------------------------------------------------------------------------
--> Center cursor while navigating search results
-------------------------------------------------------------------------------
nnoremap('n', 'nzz')
nnoremap('N', 'Nzz')

-------------------------------------------------------------------------------
--> Quickly save the current buffer or all buffers
-------------------------------------------------------------------------------
nnoremap(',w', '<CMD>update<CR>')
nnoremap(',W', '<CMD>wall<CR>')

-------------------------------------------------------------------------------
--> Close current buffer
-------------------------------------------------------------------------------
nnoremap(',d', '<CMD>bdelete<CR>')

-------------------------------------------------------------------------------
--> Move to the next/previous buffer
-------------------------------------------------------------------------------
nnoremap('<S-tab>', '<CMD>bprevious<CR>')
nnoremap('<tab>', '<CMD>bnext<CR>')

-------------------------------------------------------------------------------
--> Move to last buffer
-------------------------------------------------------------------------------
nnoremap(";;", '<CMD>b#<CR>')

-------------------------------------------------------------------------------
--> Switching windows
-------------------------------------------------------------------------------
noremap('<A-j>', '<C-w>j')
noremap('<A-k>', '<C-w>k')
noremap('<A-l>', '<C-w>l')
noremap('<A-h>', '<C-w>h')
-- Temporary fix for macOS using the "US International - PC" layout
noremap('∆', '<C-w>j')
noremap('˚', '<C-w>k')
noremap('¬', '<C-w>l')
noremap('˙', '<C-w>h')

-------------------------------------------------------------------------------
--> Tab splits
-------------------------------------------------------------------------------
nnoremap('<C-\\>', '<CMD>vsplit<CR>')
nnoremap('<A-\\>', '<CMD>split<CR>')

-------------------------------------------------------------------------------
--> Move line up and down in NORMAL and VISUAL modes
-- Reference: https://vim.fandom.com/wiki/Moving_lines_up_or_down
-------------------------------------------------------------------------------
nnoremap('<C-j>', '<CMD>move .+1<CR>')
nnoremap('<C-k>', '<CMD>move .-2<CR>')
xnoremap('<C-j>', ":move '>+1<CR>gv=gv")
xnoremap('<C-k>', ":move '<-2<CR>gv=gv")

-------------------------------------------------------------------------------
--> Use <leader>v for Visual Block Mode
-- Useful when Ctrl+V and Ctrl+Q are not forwarded to Neovim (e.g. VS Code)
-------------------------------------------------------------------------------
nnoremap('<leader>v', '<C-v>')

-------------------------------------------------------------------------------
--> Keep cursor in the same place when joining lines
-------------------------------------------------------------------------------
-- nnoremap('J', 'mzJ`z')

-------------------------------------------------------------------------------
--> Use operator pending mode to visually select the whole buffer
-- e.g. dAA = delete buffer ALL, yAA = copy whole buffer ALL
-------------------------------------------------------------------------------
onoremap('AA', ':<C-u>normal! mzggVG<CR>`z')
xnoremap('AA', ':<C-u>normal! ggVG<CR>')

-------------------------------------------------------------------------------
--> Clean search highlight with ,<space>
-------------------------------------------------------------------------------
nnoremap(',<space>', ':noh<CR>', { silent = true })

-------------------------------------------------------------------------------
--> Execute selection
-- A better alternative is to edit the command line with C-f
-------------------------------------------------------------------------------
-- vnoremap('<leader>es', ':<C-u>exec join(getline("\'<","\'>"),"\n")<CR>')

-------------------------------------------------------------------------------
--> Replace current word
--  Also check Treesitter's smart_rename
-------------------------------------------------------------------------------
nnoremap('<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-------------------------------------------------------------------------------
--> Stay in visual mode after indenting with '>' or '<'
-------------------------------------------------------------------------------
vnoremap('<', '<gv')
vnoremap('>', '>gv')

-------------------------------------------------------------------------------
--> Map Ctrl-Backspace to delete the previous word
--  Not the same was <C-w> that erases the previous WORD
--  In my terminal, Control+backspace sends  (U+0008)
-------------------------------------------------------------------------------
inoremap('<C-BS>', '<C-\\><C-o>db')
inoremap('<C-h>', '<C-\\><C-o>db')

-------------------------------------------------------------------------------
--> Copy/Paste/Cut
-------------------------------------------------------------------------------
-- Delete without overwriting last yank (delete to the black hole register "_)
nnoremap('x', '"_x')
nnoremap('d', '"_d')
nnoremap('D', '"_D')
vnoremap('d', '"_d')
vnoremap('x', '"_x')

-- Normal delete using the <leader> key
-- Use <leader>x to cut to system clipboard
nnoremap('<leader>d', '""d')
nnoremap('<leader>D', '""D')
vnoremap('<leader>d', '""d')

-- Y copy from cursor to last-non-blank-char
nnoremap('Y', 'yg_')

-- Copy to system clipboard
nnoremap('<leader>y', '"+y')
nnoremap('<leader>Y', '"+yg_')
vnoremap('<leader>y', '"+y')

-- Cut to system clipboard
vnoremap('<leader>x', '"+x')
nnoremap('<leader>x', '"+x')
nnoremap('<leader>X', '"+X')

-- Paste from system clipboard
vnoremap('<leader>p', '"+p')
vnoremap('<leader>P', '"+P')
nnoremap('<leader>p', '"+p')
nnoremap('<leader>P', '"+P')

-- Append line to register a
-- Clear register with qaq before using
nnoremap(',,y', '"Ayy')
nnoremap(',,p', '"ap')


-- Make p paste from "0 (what was yanked without specifiying a register)
-- instead of from the unnamed register ("").
--
-- The unnamed register ("") points to the last used register ("+ in the
-- commands above), except when using the black hole register ("_).
--
-- The loop below is necessary to recover the hability to use p with other
-- registers.
-- noremap('p', '"0p')
-- noremap('P', '"0P')
--
-- registers = { '"', '*', '+', '-', '.', ':', '%', '/', '=', '1', '2', '3', '4',
--     '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
--     'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y',
--     'z' }
-- for r in registers do
--   noremap(r.p, r.p)
--   noremap(r.P, r.P)
-- end

-------------------------------------------------------------------------------
--> Remove trailing whitespaces
-------------------------------------------------------------------------------
local command = vim.api.nvim_create_user_command
command('FixWhitespace', ':%s/\\s\\+$//e', { desc = 'Remove trailing whitespaces' })

-------------------------------------------------------------------------------
--> Fix line endings
-------------------------------------------------------------------------------
-- nnoremap('<leader>rl', ':e ++ff=dos<CR> :set ff=unix<CR>')
-- nnoremap('<leader>rl', ':%s/\\r$//<CR>')
command('FixLineEnding', ':%s/\\r$//e', { desc = 'Remove trailing CR' })
