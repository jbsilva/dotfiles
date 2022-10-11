local M = {}

function M.config()
  require('Comment').setup()

  -- Add a space b/w comment and the line
  padding = true
end

return M
