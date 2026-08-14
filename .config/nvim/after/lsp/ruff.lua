-------------------------------------------------------------------------------
--> ruff
--
-- Lint and import sorting for Python. The type checker alongside it is chosen
-- in plugins/config/lsp.lua; ruff attaches whichever one that is.
-------------------------------------------------------------------------------
---@type vim.lsp.Config
return {
  init_options = {
    settings = {
      -- Only a fallback: a project's own pyproject.toml or ruff.toml wins.
      lineLength = 88,
      organizeImports = true,
    },
  },
}
