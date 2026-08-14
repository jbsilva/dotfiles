-------------------------------------------------------------------------------
--> typos_lsp
--
-- The same checker the `typos` pre-commit hook runs, as a language server, so
-- the misspellings that would block a commit show up while typing instead.
-- It reads the repo's own typos.toml, including its allow-list, so the two
-- never disagree.
--
-- nvim-lspconfig already supplies cmd and the root_markers (typos.toml,
-- _typos.toml, .typos.toml, pyproject.toml, Cargo.toml).
--
-- Hint severity: this is advisory, and the pre-commit hook is the actual gate.
-- At Warning it would land in ]d navigation alongside real problems.
-------------------------------------------------------------------------------
---@type vim.lsp.Config
return {
  init_options = {
    diagnosticSeverity = 'Hint',
  },
}
