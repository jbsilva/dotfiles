-------------------------------------------------------------------------------
--> ty
--
-- Astral's Python type checker, same people as ruff, and far faster than
-- pyright. Still pre-1.0, so it is not the default -- see the
-- python_type_checkers list in plugins/config/lsp.lua and :PyTypeChecker.
--
-- nvim-lspconfig supplies cmd, filetypes and root_markers. ty finds the
-- project environment itself, from ty.toml/pyproject.toml or $VIRTUAL_ENV, so
-- there is no pythonPath to set the way pyright needs one.
-------------------------------------------------------------------------------
---@type vim.lsp.Config
return {
  settings = {
    ty = {
      -- Match pyright's behaviour here: report for the files that are open
      -- rather than crawling the whole project on every change.
      diagnosticMode = 'openFilesOnly',
    },
  },
}
