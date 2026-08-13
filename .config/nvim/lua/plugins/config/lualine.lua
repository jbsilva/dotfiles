local M = {}

function M.config()
  -- git-blame draws into the statusline instead of as virtual text.
  vim.g.gitblame_display_virtual_text = 0
  local git_blame = require('gitblame')

  require('lualine').setup({
    options = {
      -- 'auto' derives the statusline colours from whatever colorscheme is
      -- active, so switching themes just works.
      --
      -- This used to be the literal string 'tokyonight'. That is a real lualine
      -- theme, but tokyonight was lazy-loaded, so at the moment lualine started
      -- the module did not exist yet and lualine warned:
      --   theme 'tokyonight' not found, falling back to 'auto'
      -- tokyonight now loads eagerly (see plugins/init.lua), and 'auto' picks
      -- it up without naming it twice.
      theme = 'auto',
      globalstatus = true,
    },
    sections = {
      -- Keep the filename; append the blame text after it. The previous config
      -- replaced lualine_c outright, which dropped the filename from the
      -- statusline entirely.
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
