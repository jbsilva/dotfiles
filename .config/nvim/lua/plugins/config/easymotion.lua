local M = {}

function M.setup()
  ---------------------------------------------------------------------------
  --> Keymaps
  ---------------------------------------------------------------------------
  local remap = require("keymap")
  local nnoremap = remap.nnoremap

  -- Avoid repetitive use of the h j k and l keys
  nnoremap('<leader><leader>l', '<Plug>(easymotion-lineforward)')
  nnoremap('<leader><leader>j', '<Plug>(easymotion-j)')
  nnoremap('<leader><leader>k', '<Plug>(easymotion-k)')
  nnoremap('<leader><leader>h', '<Plug>(easymotion-linebackward)')
end

function M.config()
  -- Keep cursor column when JK motion
  vim.g.EasyMotion_startofline = 0
  -- Turn on case-insensitive feature
  vim.g.EasyMotion_smartcase = 1
end

return M
