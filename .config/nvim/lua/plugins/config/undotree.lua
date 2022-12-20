local M = {}

function M.setup()
  ---------------------------------------------------------------------------
  --> Keymaps
  ---------------------------------------------------------------------------
  local remap = require("mapmodes")
  local nnoremap = remap.nnoremap

  -- Toggle Undotree
  nnoremap('<leader>u', vim.cmd.UndotreeToggle)
end

return M
