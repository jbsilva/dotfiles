-------------------------------------------------------------------------------
--> eslint
--
-- workingDirectories auto: eslint resolves its config from the directory of
-- the file being linted, which is what monorepos with a config per package
-- need.
--
-- Fix-on-save is wired up in plugins/config/lsp.lua, per buffer, so it only
-- applies where this server actually attached.
-------------------------------------------------------------------------------
---@type vim.lsp.Config
return {
  settings = { workingDirectories = { mode = 'auto' } },
}
