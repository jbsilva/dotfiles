-------------------------------------------------------------------------------
--> lua_ls
--
-- Types for the Neovim API and for plugins come from lazydev, which loads them
-- on demand. Listing the whole runtimepath as `workspace.library` instead
-- makes lua_ls index every plugin on every start.
--
-- .config/nvim/.luarc.json mirrors these, for editors that run lua_ls without
-- this config -- VS Code, where `vim` would otherwise be an undefined global
-- on every line. A workspace .luarc.json outranks what a client sends, so it
-- deliberately omits workspace.library and leaves that to lazydev.
-------------------------------------------------------------------------------
---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- stylua formats these files, via conform and the pre-commit hook.
      format = { enable = false },
    },
  },
}
