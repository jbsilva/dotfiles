-------------------------------------------------------------------------------
--> Neotest
--
-- Runs tests from inside the editor, with results as signs in the gutter.
-- Adapters are limited to what is actually written here: Python and JS/TS.
--
--   <leader>tt  run every test in the current file
--   <leader>tn  run the nearest test
--   <leader>td  debug the nearest test (via nvim-dap)
--   <leader>ts  toggle the summary panel
--   <leader>to  open the output of the last run
--
-- The previous version of this file configured neotest-rust; it was replaced
-- along with the plugin being re-enabled.
-------------------------------------------------------------------------------
local M = {}

function M.config()
  local neotest = require('neotest')

  neotest.setup({
    adapters = {
      -----------------------------------------------------------------------
      --> Python
      --
      -- runner is left unset so the adapter detects pytest vs unittest from
      -- the project. `python` is the same lookup pyright uses, shared from
      -- plugins.config.util. The adapter calls it with the project root, so
      -- passing the function itself hands it a root rather than the cwd.
      -----------------------------------------------------------------------
      require('neotest-python')({
        dap = { justMyCode = false },
        python = require('plugins.config.util').venv_python,
      }),

      -----------------------------------------------------------------------
      --> JavaScript / TypeScript (jest)
      --
      -- jestCommand uses the locally installed jest so the project's own
      -- config and plugins are honoured, rather than a global install.
      -----------------------------------------------------------------------
      require('neotest-jest')({
        jestCommand = 'npx jest',
        env = { CI = true },
        cwd = function()
          return vim.fn.getcwd()
        end,
      }),
    },

    -- Show a sign in the gutter for pass/fail rather than only in the summary.
    status = { virtual_text = true },
    output = { open_on_run = false },
    quickfix = {
      -- Populate the quickfix list but do not steal focus on every run.
      enabled = true,
      open = false,
    },
  })
end

return M
