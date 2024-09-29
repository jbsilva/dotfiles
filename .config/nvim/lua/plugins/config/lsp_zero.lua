----------------------------------------------------------
--> LSP Zero
--
--  :LspZeroFormat
--  :LspZeroWorkspaceList
--
--  K: display information about symbol
--  gD: jumps to declaration
--  gi: lists all implementations of symbol
--  go: jumps to definition of the type
--  gr: list all references to symbol
--  <F2> renames all references of the symbol
--
--  gl: show diagnostics
--  [d: previous diagnosticvim.lsp.buf.rename().
--  ]d: next diagnostic
--
--  https://github.com/VonHeikemen/lsp-zero.nvim
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
----------------------------------------------------------
local M = {}

function M.config()
  local lsp_zero = require('lsp-zero')

  ----------------------------------------------------------
  --> CMP
  ----------------------------------------------------------
  -- local cmp = require('cmp')
  -- local cmp_mappings = lsp_zero.defaults.cmp_mappings()
  --
  -- -- Disable completion with tab
  -- cmp_mappings['<Tab>'] = nil
  -- cmp_mappings['<S-Tab>'] = nil
  -- -- Disable completion with Enter
  -- cmp_mappings['<CR>'] = nil
  -- -- Use Right arrow to accept completion
  -- cmp_mappings['<Right>'] = cmp.mapping.confirm {
  --   behavior = cmp.ConfirmBehavior.Insert,
  --   select = true,
  -- }
  --
  -- lsp_zero.setup_nvim_cmp({
  --   mapping = cmp_mappings,
  -- })

  ----------------------------------------------------------
  --> Mason-dap
  ----------------------------------------------------------
  require('mason-nvim-dap').setup({
    ensure_installed = {
      'python',
    },
    automatic_setup = true,
  })
end

return M
