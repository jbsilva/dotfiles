-------------------------------------------------------------------------------
--> vtsls
--
-- Wraps the official TypeScript language server, and is better maintained than
-- the old tsserver integration.
--
-- Inlay hints are on for parameter names and types; toggle them per buffer
-- with <leader>th.
-------------------------------------------------------------------------------
local inlay_hints = {
  parameterNames = { enabled = 'literals' },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = false },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}

---@type vim.lsp.Config
return {
  settings = {
    typescript = { inlayHints = inlay_hints, updateImportsOnFileMove = { enabled = 'always' } },
    javascript = { inlayHints = inlay_hints },
    vtsls = {
      -- Surface the full error text rather than truncating long TS unions.
      experimental = { completion = { enableServerSideFuzzyMatch = true } },
    },
  },
}
