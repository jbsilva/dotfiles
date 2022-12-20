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
nnoremap('<leader>w', '<CMD>update<CR>')
nnoremap('<leader>W', '<CMD>wall<CR>')

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
--> Keep cursor in the same place when joining lines
-------------------------------------------------------------------------------
-- nnoremap('J', 'mzJ`z')

-------------------------------------------------------------------------------
--> Use operator pending mode to visually select the whole buffer
-- e.g. dA = delete buffer ALL, yA = copy whole buffer ALL
-------------------------------------------------------------------------------
onoremap('A', ':<C-u>normal! mzggVG<CR>`z')
xnoremap('A', ':<C-u>normal! ggVG<CR>')

-------------------------------------------------------------------------------
--> Clean search highlight with ,<space>
-------------------------------------------------------------------------------
nnoremap(',<space>', ':noh<CR>', { silent = true })

-------------------------------------------------------------------------------
--> Execute selection
-------------------------------------------------------------------------------
-- vnoremap('<leader>es', ':<C-u>exec join(getline("\'<","\'>"),"\n")<CR>')

-------------------------------------------------------------------------------
--> Replace current word
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

-- Make p paste from "0 (what was yanked without specifiying a register)
-- instead of from the unnamed register ("").
--
-- The unnamed register ("") points to the last used register ("+ in the
-- commands above), except when using the black hole register ("_).
--
-- The loop below is necessary to recover the hability to use p with other
-- registers.
noremap('p', '"0p')
noremap('P', '"0P')

-- registers = {'"','*','+','-','.',':','%','/','=','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
-- for s:i in registers do
--     execute 'noremap "'.s:i.'p "'.s:i.'p'
--     execute 'noremap "'.s:i.'P "'.s:i.'P'
-- end

-------------------------------------------------------------------------------
--> Remove trailing whitespaces
-------------------------------------------------------------------------------
local command = vim.api.nvim_create_user_command
command('FixWhitespace', ':%s/\\s\\+$//e', { desc = 'Remove trailing whitespaces' })

