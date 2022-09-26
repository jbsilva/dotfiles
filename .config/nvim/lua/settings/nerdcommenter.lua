local M = {}

function M.config()
  -- Add spaces after comment delimiters by default
  vim.g.NERDSpaceDelims = 1

  -- Align line-wise comment delimiters flush left instead of following code indentation
  vim.g.NERDDefaultAlign = 'left'
end

return M
