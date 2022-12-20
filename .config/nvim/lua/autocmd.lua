local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local command = vim.api.nvim_create_user_command

-------------------------------------------------------------------------------
--> Highlight the region on yank
-------------------------------------------------------------------------------
local yank_group = augroup('HighlightYank', {})

autocmd(
  'TextYankPost',
  {
    group = yank_group,
    pattern = '*',
    callback = function()
      vim.highlight.on_yank(
      {
        higroup = 'IncSearch',
        timeout = 200,
      })
    end,
  }
)

-------------------------------------------------------------------------------
--> Hybrid relative line numbers
-- Disable rnu on insert mode and when out of focus
-------------------------------------------------------------------------------
local number_group = augroup('numberToggle', { clear = true })

autocmd(
  { 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' },
  {
    group = number_group,
    pattern = { '*' },
    command = "if &nu && mode() != 'i' | set rnu | endif",
  }
)

autocmd(
  { 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' },
  {
    group = number_group,
    pattern = { '*' },
    command = 'if &nu | set nornu | endif',
  }
)

-------------------------------------------------------------------------------
--> Remember last cursor position
--  TODO: fix undesired jumps
-------------------------------------------------------------------------------
-- autocmd(
--   'BufReadPost',
--   {
--     callback = function()
--       local row, col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
--       if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
--         vim.api.nvim_win_set_cursor(0, { row, col })
--       end
--     end,
--   }
-- )

-------------------------------------------------------------------------------
--> Automatically run :PackerCompile whenever plugins.lua is updated
-------------------------------------------------------------------------------
autocmd(
  'BufWritePost',
  {
    group = augroup('Packer', { clear = true }),
    pattern = 'init.lua',
    command = 'source <afile> | PackerCompile',
  }
)

-------------------------------------------------------------------------------
--> Text files
--
-- * Spell checker
--   * Deactivate correction:     `:setlocal nospell`
--   * Commands (`:help spell`):  `[s`, `]s`, `z=`, `zg`, `zw`, `:spellr`
-- * Text with: 80 columns
-------------------------------------------------------------------------------
autocmd(
  { 'BufEnter', 'BufWinEnter', 'TabEnter' },
  {
    group = augroup('Text', { clear = true }),
    pattern = '*.txt',
    command = 'setlocal textwidth=80 spell spelllang=en_us',
  }
)

-------------------------------------------------------------------------------
--> Remove trailing whitespaces
-------------------------------------------------------------------------------
command('FixWhitespace', ':%s/\\s\\+$//e', { desc = 'Remove trailing whitespaces' })

