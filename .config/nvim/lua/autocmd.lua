local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-------------------------------------------------------------------------------
--> Highlight the region on yank
-------------------------------------------------------------------------------
local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    -- vim.highlight was renamed to vim.hl in Neovim 0.11.
    local hl = vim.hl or vim.highlight
    hl.on_yank({
      higroup = 'IncSearch',
      timeout = 200,
    })
  end,
})

-------------------------------------------------------------------------------
--> Hybrid relative line numbers
-- Disable rnu on insert mode and when out of focus
-------------------------------------------------------------------------------
local number_group = augroup('numberToggle', { clear = true })

autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
  group = number_group,
  pattern = { '*' },
  command = "if &nu && mode() != 'i' | set rnu | endif",
})

autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  group = number_group,
  pattern = { '*' },
  command = 'if &nu | set nornu | endif',
})

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
--> Large files
--
-- Treesitter parsing, LSP attach and syntax highlighting are all O(file size).
-- Past a threshold they make opening a file take seconds and every keystroke
-- lag. Above 1 MB, open the file as plain text instead.
--
-- :e! after opening restores everything for that buffer if the file really
-- does need highlighting.
-------------------------------------------------------------------------------
local bigfile_bytes = 1024 * 1024

autocmd('BufReadPre', {
  group = augroup('BigFile', { clear = true }),
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if not ok or not stats or stats.size <= bigfile_bytes then
      return
    end

    vim.b[args.buf].large_file = true

    -- Cheaper redraws: no wrapping, no folds, no cursorline, no undo history.
    vim.opt_local.wrap = false
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.cursorline = false
    vim.opt_local.undofile = false
    vim.opt_local.swapfile = false
    vim.opt_local.list = false
    -- 'syntax off' also stops treesitter starting via the FileType autocmd.
    vim.opt_local.syntax = 'off'

    vim.notify(
      ('Large file (%.1f MB): highlighting and LSP disabled'):format(stats.size / 1024 / 1024),
      vim.log.levels.WARN
    )
  end,
})

-- Keep language servers off those buffers too.
autocmd('LspAttach', {
  group = augroup('BigFileLsp', { clear = true }),
  callback = function(args)
    if vim.b[args.buf].large_file then
      vim.schedule(function()
        vim.lsp.buf_detach_client(args.buf, args.data.client_id)
      end)
    end
  end,
})

-------------------------------------------------------------------------------
--> Text files
--
-- * Spell checker
--   * Deactivate correction:     `:setlocal nospell`
--   * Commands (`:help spell`):  `[s`, `]s`, `z=`, `zg`, `zw`, `:spellr`
-- * Text with: 80 columns
-------------------------------------------------------------------------------
autocmd({ 'BufEnter', 'BufWinEnter', 'TabEnter' }, {
  group = augroup('Text', { clear = true }),
  pattern = '*.txt',
  command = 'setlocal textwidth=80 spell spelllang=en_us',
})
