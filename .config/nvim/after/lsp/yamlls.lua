-------------------------------------------------------------------------------
--> yamlls
--
-- Schemas for GitHub workflows, docker-compose and the rest. yamlls has its
-- own schema store, but it is fetched at runtime; SchemaStore.nvim ships the
-- catalogue, so the built-in one is switched off to avoid the network call and
-- the two disagreeing.
-------------------------------------------------------------------------------
local ok, schemastore = pcall(require, 'schemastore')

---@type vim.lsp.Config
return {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = '' },
      schemas = ok and schemastore.yaml.schemas() or nil,
    },
  },
}
