local M = {}

function M.config()
  -- lua_ls reports `setup` as an undefined field. The field exists; lualine
  -- declares `local M = {}` and then replaces it wholesale with its export
  -- table at the end of the file, which defeats the inference.
  ---@diagnostic disable-next-line: undefined-field
  require('lualine').setup({
    options = {
      -- Derives the statusline colours from the active colorscheme, so
      -- switching themes needs no change here.
      theme = 'auto',
      globalstatus = true,
    },
    sections = {
      -- Filename, then the blame for the current line.
      --
      -- The blame text comes from gitsigns, which sets b:gitsigns_blame_line
      -- whenever current_line_blame is on. It populates that variable before it
      -- decides whether to draw virtual text, so current_line_blame_opts.
      -- virt_text = false (see the gitsigns spec) gives the statusline the
      -- string without also annotating the buffer. That is what git-blame.nvim
      -- was here for.
      lualine_c = {
        { 'filename', path = 1 },
        {
          function()
            return vim.b.gitsigns_blame_line or ''
          end,
          cond = function()
            return vim.b.gitsigns_blame_line ~= nil and vim.b.gitsigns_blame_line ~= ''
          end,
        },
      },
    },
    extensions = { 'quickfix', 'nvim-tree', 'lazy' },
  })
end

return M
