-------------------------------------------------------------------------------
--> jsonls
--
-- Without a schema catalogue this only checks syntax. With one it validates
-- and completes package.json, tsconfig.json, .eslintrc and the rest against
-- their published schemas.
--
-- SchemaStore.nvim is a dependency of nvim-lspconfig, so it has loaded by the
-- time a server config is resolved; the pcall is for the first start after a
-- clean checkout, before :Lazy sync has run.
-------------------------------------------------------------------------------
local ok, schemastore = pcall(require, 'schemastore')

---@type vim.lsp.Config
return {
  settings = {
    json = {
      schemas = ok and schemastore.json.schemas() or nil,
      validate = { enable = true },
    },
  },
}
