local M = {}

function M.config()
  local lsp = require('lsp-zero')
  lsp.preset('recommended')

  -- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
  lsp.ensure_installed({
    'bashls',                 -- Bash
    'html',                   -- HTML
    'jedi_language_server',   -- Python
    -- 'pyright',                -- Python
    'jsonls',                 -- Json
    'marksman',               -- Markdown
    'rust_analyzer',          -- Rust
    'sqlls',                  -- SQL
    'sumneko_lua',            -- Lua
    'terraformls',            -- Terraform
    'tsserver',               -- TypeScript
    'yamlls',                 -- Yaml
  })

  local cmp = require('cmp')
  local cmp_select = {behavior = cmp.SelectBehavior.Select}
  local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  })

  -- disable completion with tab
  -- this helps with copilot setup
  cmp_mappings['<Tab>'] = nil
  cmp_mappings['<S-Tab>'] = nil

  lsp.setup_nvim_cmp({
    mapping = cmp_mappings
  })

  lsp.nvim_workspace()

  lsp.setup()
end

return M
