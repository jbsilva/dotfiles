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
      -- the project. `python` is resolved the same way as for pyright: use
      -- the project virtualenv if there is one, since that is where pytest
      -- and the dependencies live.
      -----------------------------------------------------------------------
      require('neotest-python')({
        dap = { justMyCode = false },
        python = function()
          if vim.env.VIRTUAL_ENV then
            return vim.fs.joinpath(vim.env.VIRTUAL_ENV, 'bin', 'python')
          end
          for _, dir in ipairs({ '.venv', 'venv' }) do
            local candidate = vim.fs.joinpath(vim.uv.cwd(), dir, 'bin', 'python')
            if vim.uv.fs_stat(candidate) then
              return candidate
            end
          end
          return vim.fn.exepath('python3')
        end,
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
