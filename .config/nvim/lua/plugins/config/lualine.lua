local M = {}

function M.config()
  -- git-blame draws into the statusline instead of as virtual text.
  vim.g.gitblame_display_virtual_text = 0
  local git_blame = require('gitblame')

  require('lualine').setup({
    options = {
      -- Derives the statusline colours from the active colorscheme, so
      -- switching themes needs no change here.
      theme = 'auto',
      globalstatus = true,
    },
    sections = {
      -- Filename, then the blame text for the current line.
      lualine_c = {
        { 'filename', path = 1 },
        {
          git_blame.get_current_blame_text,
          cond = git_blame.is_blame_text_available,
        },
      },
    },
    extensions = { 'quickfix', 'nvim-tree', 'lazy' },
  })
end

return M
