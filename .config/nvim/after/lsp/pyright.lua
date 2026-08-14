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
    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = require('plugins.config.util').venv_python(config.root_dir)
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
