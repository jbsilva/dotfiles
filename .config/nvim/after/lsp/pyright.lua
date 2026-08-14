-------------------------------------------------------------------------------
--> pyright
--
-- Types, hover and navigation. ruff owns lint and import sorting, so the
-- overlapping parts are handed to it rather than reported twice.
--
-- pythonPath is resolved per project so pyright reads the project virtualenv
-- (uv/poetry `.venv`, or $VIRTUAL_ENV); without it every third-party import
-- shows as unresolved. neotest-python resolves it the same way, so the lookup
-- lives in plugins.config.util.
-------------------------------------------------------------------------------
---@type vim.lsp.Config
return {
  before_init = function(_, config)
    -- Mutated in place, through a local typed `table`. The client captures
    -- this table before before_init runs, so replacing config.settings with a
    -- new one is silently dropped; the local is only there because reaching
    -- into config.settings directly is an inject-field warning (it is typed
    -- lsp.LSPObject).
    ---@type table
    local settings = config.settings or {}
    settings.python = settings.python or {}
    settings.python.pythonPath = require('plugins.config.util').venv_python(config.root_dir)
    config.settings = settings
  end,
  settings = {
    pyright = {
      -- Let ruff own import organisation.
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        typeCheckingMode = 'basic',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}
