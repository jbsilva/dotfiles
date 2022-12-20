local M = {}

function M.config()
  vim.g.gitblame_display_virtual_text = 0
  local git_blame = require('gitblame')

  require('lualine').setup {
    sections = {
      lualine_c = {
        { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available }
      }
    },
    options = {
      theme = 'tokyonight',
    },
    extensions = { 'quickfix', 'nvim-tree' }
  }
end

return M
