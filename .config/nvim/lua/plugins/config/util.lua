-------------------------------------------------------------------------------
--> Helpers shared between the plugin config modules
-------------------------------------------------------------------------------
local M = {}

-------------------------------------------------------------------------------
--> Interpreter for a Python project
--
-- pyright and neotest-python both need the project's own virtualenv. Without
-- it pyright reports every third-party import as unresolved, and neotest runs
-- the suite against an interpreter that has neither pytest nor the project
-- dependencies installed.
--
-- `root` is the project root, which the callers are handed by pyright's
-- before_init and by the neotest adapter. It is not always the cwd -- Neovim
-- may have been started a directory above the project -- so it is passed in
-- rather than looked up here.
-------------------------------------------------------------------------------
function M.venv_python(root)
  if vim.env.VIRTUAL_ENV then
    return vim.fs.joinpath(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  for _, dir in ipairs({ '.venv', 'venv', '.direnv' }) do
    local candidate = vim.fs.joinpath(root or vim.uv.cwd(), dir, 'bin', 'python')
    if vim.uv.fs_stat(candidate) then
      return candidate
    end
  end

  return vim.fn.exepath('python3')
end

return M
