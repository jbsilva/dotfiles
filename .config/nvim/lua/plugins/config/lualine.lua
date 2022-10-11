local M = {}

function M.config()
  require('lualine').setup {
    options = {
      theme = 'tokyonight',
    },
    extensions = { 'quickfix', 'nvim-tree' }
  }
end

return M
